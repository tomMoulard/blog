---
title: "Factory vs Singleton: Why Your Go HTTP API Deserves Better Than Global State"
date: 2025-12-05T12:00:00+02:00
draft: false
author: Tom Moulard
url: /factory-vs-singleton-go-http-apis
type: post
tags: ["go", "golang", "design-patterns", "factory", "singleton", "testing", "http", "api", "best-practices", "mocktail", "testify", "mocking"]
categories: ["Go", "Architecture", "tutoriel"]
---

# The 3 AM Production Nightmare

Picture this: It's 3 AM. Production is on fire. You're desperately trying to debug why your HTTP API is returning cached data from *yesterday*. You trace the issue to your HTTP client... which is a singleton... that someone initialized with a 24-hour cache... and there's no way to reset it without restarting the entire service.

I've been there. Twice, actually. The second time was worse because I *knew* better but had inherited the codebase.

This post is about why the **Factory pattern** beats **Singleton** for HTTP clients in Go. Not because some design pattern book says so, but because I've debugged enough production incidents to have opinions.

---

## The Two Approaches

### The Singleton Pattern: The "One Ring to Rule Them All" Approach

The Singleton pattern ensures a class has only **one instance** and provides a global point of access to it. In Go, it typically looks like this:

```go
package httpclient

import (
	"net/http"
	"sync"
	"time"
)

// Singleton HTTP client - there can be only one!
var (
	instance *http.Client
	once     sync.Once
)

// GetClient returns THE HTTP client. The only one. Forever.
func GetClient() *http.Client {
	once.Do(func() {
		instance = &http.Client{
			Timeout: 30 * time.Second,
			Transport: &http.Transport{
				MaxIdleConns:        100,
				MaxIdleConnsPerHost: 10,
				IdleConnTimeout:     90 * time.Second,
			},
		}
	})
	return instance
}
```

Looks clean, right? One client, thread-safe initialization with `sync.Once`, everyone's happy.

Now let's use it in an HTTP handler:

```go
package api

import (
	"encoding/json"
	"net/http"

	"myapp/httpclient"
)

type UserHandler struct{}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	// Using our singleton client
	client := httpclient.GetClient()

	resp, err := client.Get("https://api.example.com/users/123")
	if err != nil {
		http.Error(w, "Failed to fetch user", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var user User
	if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
		http.Error(w, "Failed to decode user", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(user)
}

type User struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}
```

### The Factory Pattern: The "Made to Order" Approach

The Factory pattern creates objects without exposing the creation logic. In Go, we typically combine it with **dependency injection** and **interfaces**:

```go
package httpclient

import (
	"net/http"
	"time"
)

// HTTPClient defines what we need from an HTTP client
type HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
	Get(url string) (*http.Response, error)
}

// ClientConfig holds configuration for creating clients
type ClientConfig struct {
	Timeout             time.Duration
	MaxIdleConns        int
	MaxIdleConnsPerHost int
	IdleConnTimeout     time.Duration
}

// DefaultConfig returns sensible defaults
func DefaultConfig() ClientConfig {
	return ClientConfig{
		Timeout:             30 * time.Second,
		MaxIdleConns:        100,
		MaxIdleConnsPerHost: 10,
		IdleConnTimeout:     90 * time.Second,
	}
}

// NewClient creates a new HTTP client with the given config
// This is our Factory function!
func NewClient(cfg ClientConfig) HTTPClient {
	return &http.Client{
		Timeout: cfg.Timeout,
		Transport: &http.Transport{
			MaxIdleConns:        cfg.MaxIdleConns,
			MaxIdleConnsPerHost: cfg.MaxIdleConnsPerHost,
			IdleConnTimeout:     cfg.IdleConnTimeout,
		},
	}
}
```

And the handler using dependency injection:

```go
package api

import (
	"encoding/json"
	"io"
	"net/http"

	"myapp/httpclient"
)

// Maximum response body size to prevent memory exhaustion (1MB)
const maxResponseBodySize = 1 << 20

type UserHandler struct {
	client httpclient.HTTPClient // Injected dependency!
}

// NewUserHandler is a factory for creating UserHandlers
func NewUserHandler(client httpclient.HTTPClient) *UserHandler {
	return &UserHandler{client: client}
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	// Use context from incoming request for proper cancellation
	req, err := http.NewRequestWithContext(r.Context(), http.MethodGet, "https://api.example.com/users/123", nil)
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	resp, err := h.client.Do(req)
	if err != nil {
		http.Error(w, "Failed to fetch user", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Check status code before processing
	if resp.StatusCode != http.StatusOK {
		// Drain body to allow connection reuse
		io.Copy(io.Discard, io.LimitReader(resp.Body, maxResponseBodySize))
		http.Error(w, "Upstream API error", http.StatusBadGateway)
		return
	}

	// Limit response body size to prevent memory exhaustion
	limitedBody := io.LimitReader(resp.Body, maxResponseBodySize)

	var user User
	if err := json.NewDecoder(limitedBody).Decode(&user); err != nil {
		http.Error(w, "Failed to decode user", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

type User struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}
```

"But that's more code!" Yes. About 40 more lines. I'll take 40 lines over a 3 AM debugging session any day.

---

## Testing: Where Singleton Falls Apart

Here's where it gets painful. Try writing tests for both approaches.

### Testing the Singleton Approach (The Hard Way)

```go
package api

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestUserHandler_GetUser_Singleton(t *testing.T) {
	// Problem 1: How do we mock httpclient.GetClient()?
	// The singleton is already initialized!

	// Option A: Create a test server (integration test, not unit test)
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"id": 123, "name": "Test User"}`))
	}))
	defer ts.Close()

	// But wait... our handler hardcodes "https://api.example.com"
	// We can't change the URL without modifying production code!

	// Option B: Use build tags or test hooks (yuck)
	// Option C: Use a global variable that can be swapped (double yuck)
	// Option D: Cry.

	t.Skip("This test demonstrates why singletons are hard to test")
}

func TestUserHandler_GetUser_Singleton_Parallel(t *testing.T) {
	// Problem 2: Tests can't run in parallel safely
	// If one test modifies the singleton state, others are affected

	t.Parallel() // This is asking for trouble!

	// Imagine multiple tests running simultaneously:
	// - Test A wants the client to timeout
	// - Test B wants the client to return errors
	// - Test C wants the client to succeed
	// They're all sharing the SAME client instance!

	t.Skip("Parallel tests with singletons are dangerous")
}
```

### Testing the Factory Approach (The Natural Way)

```go
package api

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
)

// MockHTTPClient is our test double
type MockHTTPClient struct {
	DoFunc func(req *http.Request) (*http.Response, error)
}

func (m *MockHTTPClient) Do(req *http.Request) (*http.Response, error) {
	return m.DoFunc(req)
}

func (m *MockHTTPClient) Get(url string) (*http.Response, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	return m.Do(req)
}

func TestUserHandler_GetUser_Success(t *testing.T) {
	t.Parallel() // Safe! Each test gets its own mock

	expectedUser := User{ID: 123, Name: "Test User"}

	mock := &MockHTTPClient{
		DoFunc: func(req *http.Request) (*http.Response, error) {
			// Verify the request is correct
			if req.URL.String() != "https://api.example.com/users/123" {
				t.Errorf("unexpected URL: %s", req.URL)
			}

			// Return our mock response
			body, _ := json.Marshal(expectedUser)
			return &http.Response{
				StatusCode: http.StatusOK,
				Body:       io.NopCloser(bytes.NewReader(body)),
				Header:     make(http.Header),
			}, nil
		},
	}

	handler := NewUserHandler(mock)

	req := httptest.NewRequest(http.MethodGet, "/user", nil)
	rec := httptest.NewRecorder()

	handler.GetUser(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", rec.Code)
	}

	var user User
	if err := json.NewDecoder(rec.Body).Decode(&user); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}

	if user.ID != expectedUser.ID || user.Name != expectedUser.Name {
		t.Errorf("expected %+v, got %+v", expectedUser, user)
	}
}

func TestUserHandler_GetUser_NetworkError(t *testing.T) {
	t.Parallel() // Still safe!

	mock := &MockHTTPClient{
		DoFunc: func(req *http.Request) (*http.Response, error) {
			return nil, &net.OpError{Op: "dial", Err: errors.New("connection refused")}
		},
	}

	handler := NewUserHandler(mock)

	req := httptest.NewRequest(http.MethodGet, "/user", nil)
	rec := httptest.NewRecorder()

	handler.GetUser(rec, req)

	if rec.Code != http.StatusInternalServerError {
		t.Errorf("expected status 500, got %d", rec.Code)
	}
}

func TestUserHandler_GetUser_InvalidJSON(t *testing.T) {
	t.Parallel() // Always safe!

	mock := &MockHTTPClient{
		DoFunc: func(req *http.Request) (*http.Response, error) {
			return &http.Response{
				StatusCode: http.StatusOK,
				Body:       io.NopCloser(bytes.NewReader([]byte("not json"))),
				Header:     make(http.Header),
			}, nil
		},
	}

	handler := NewUserHandler(mock)

	req := httptest.NewRequest(http.MethodGet, "/user", nil)
	rec := httptest.NewRecorder()

	handler.GetUser(rec, req)

	if rec.Code != http.StatusInternalServerError {
		t.Errorf("expected status 500, got %d", rec.Code)
	}
}
```

Three tests, all parallel, each with isolated mock behavior. This is how testing should work.

### Table-Driven Tests: The Factory Pattern's Best Friend

```go
// Note: This test requires the imports from the previous test file:
// "bytes", "errors", "io", "net/http", "net/http/httptest", "testing"

func TestUserHandler_GetUser_TableDriven(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name           string
		mockResponse   *http.Response
		mockError      error
		expectedStatus int
		expectedBody   string
	}{
		{
			name: "success",
			mockResponse: &http.Response{
				StatusCode: http.StatusOK,
				Body:       io.NopCloser(bytes.NewReader([]byte(`{"id":1,"name":"Alice"}`))),
				Header:     make(http.Header),
			},
			expectedStatus: http.StatusOK,
			expectedBody:   `{"id":1,"name":"Alice"}`,
		},
		{
			name:           "network error",
			mockError:      errors.New("connection refused"),
			expectedStatus: http.StatusInternalServerError,
		},
		{
			name: "api returns 404",
			mockResponse: &http.Response{
				StatusCode: http.StatusNotFound,
				Body:       io.NopCloser(bytes.NewReader([]byte(`{"error":"not found"}`))),
				Header:     make(http.Header),
			},
			expectedStatus: http.StatusBadGateway, // Handler now properly checks status codes!
		},
		{
			name: "invalid json response",
			mockResponse: &http.Response{
				StatusCode: http.StatusOK,
				Body:       io.NopCloser(bytes.NewReader([]byte(`{invalid}`))),
				Header:     make(http.Header),
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			mock := &MockHTTPClient{
				DoFunc: func(req *http.Request) (*http.Response, error) {
					return tt.mockResponse, tt.mockError
				},
			}

			handler := NewUserHandler(mock)
			req := httptest.NewRequest(http.MethodGet, "/user", nil)
			rec := httptest.NewRecorder()

			handler.GetUser(rec, req)

			if rec.Code != tt.expectedStatus {
				t.Errorf("expected status %d, got %d", tt.expectedStatus, rec.Code)
			}
		})
	}
}
```

> **Note for Go 1.22+**: The `tt := tt` line to capture the loop variable is no longer needed in Go 1.22 and later, as loop variables are now scoped per iteration. I've removed it from this example.

### Generating Mocks with Mocktail: Stop Writing Boilerplate!

Writing mocks by hand gets old fast. I've wasted too many hours writing boilerplate `DoFunc` callbacks.

[**Mocktail**](https://github.com/paperballs/mocktail) generates strongly-typed mocks using `testify/mock`. The key difference from other generators: it uses typed methods instead of string-based calls. When your interface changes, compilation fails. No more "forgot to update the mock" bugs.

#### Installing Mocktail

```bash
go install github.com/paperballs/mocktail@latest
```

#### Setting Up Mocks

Create a file named `mock_test.go` in your package and add directives for the interfaces you want to mock:

```go
package api

// mocktail:HTTPClient
```

Then run `mocktail` at the root of your project:

```bash
mocktail
```

Mocktail generates a `mock_gen_test.go` file with your mock implementation.

#### Using Mocktail-Generated Mocks

Here's how our tests look with Mocktail-generated mocks:

```go
package api

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestUserHandler_GetUser_WithMocktail(t *testing.T) {
	t.Parallel()

	expectedUser := User{ID: 123, Name: "Test User"}
	body, _ := json.Marshal(expectedUser)

	// Create mock with Mocktail's fluent API
	mock := newHTTPClientMock(t).
		OnDo().TypedReturns(&http.Response{
			StatusCode: http.StatusOK,
			Body:       io.NopCloser(bytes.NewReader(body)),
			Header:     make(http.Header),
		}, nil).Once()

	handler := NewUserHandler(mock)

	req := httptest.NewRequest(http.MethodGet, "/user", nil)
	rec := httptest.NewRecorder()

	handler.GetUser(rec, req)

	require.Equal(t, http.StatusOK, rec.Code)

	var user User
	json.NewDecoder(rec.Body).Decode(&user)
	assert.Equal(t, expectedUser.ID, user.ID)
	assert.Equal(t, expectedUser.Name, user.Name)
}

func TestUserHandler_GetUser_NetworkError_WithMocktail(t *testing.T) {
	t.Parallel()

	// Fluent syntax for error scenarios
	mock := newHTTPClientMock(t).
		OnDo().TypedReturns(nil, errors.New("connection refused")).Once()

	handler := NewUserHandler(mock)

	req := httptest.NewRequest(http.MethodGet, "/user", nil)
	rec := httptest.NewRecorder()

	handler.GetUser(rec, req)

	assert.Equal(t, http.StatusInternalServerError, rec.Code)
}
```

#### Why Mocktail Over Hand-Written Mocks?

| Aspect | Hand-Written Mocks | Mocktail |
|--------|-------------------|----------|
| **Setup time** | Write struct + all methods | One comment directive |
| **Type safety** | Manual, error-prone | Compiler-enforced |
| **Refactoring** | Manual updates everywhere | Regenerate, compiler catches breaks |
| **Fluent API** | DIY or nothing | Built-in `.OnMethod().TypedReturns().Once()` |
| **Assertions** | Manual call counting | Automatic with `testify/mock` |

#### The Generated Mock

Here's what Mocktail generates for our `HTTPClient` interface:

```go
// Code generated by mocktail; DO NOT EDIT.

package api

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/mock"
)

// httpClientMock mock of HTTPClient.
type httpClientMock struct{ mock.Mock }

// newHTTPClientMock creates a new httpClientMock.
func newHTTPClientMock(tb testing.TB) *httpClientMock {
	tb.Helper()

	m := &httpClientMock{}
	m.Mock.Test(tb)

	tb.Cleanup(func() { m.AssertExpectations(tb) })

	return m
}

// httpClientMockDo_Call is a method call on Do.
type httpClientMockDo_Call struct {
	*mock.Call
	Parent *httpClientMock
}

// Do implements HTTPClient.Do.
func (m *httpClientMock) Do(req *http.Request) (*http.Response, error) {
	ret := m.Called(req)
	return ret.Get(0).(*http.Response), ret.Error(1)
}

// OnDo sets up expectation for Do.
func (m *httpClientMock) OnDo(req ...any) *httpClientMockDo_Call {
	// ... expectation setup
}

// TypedReturns sets typed return values.
func (c *httpClientMockDo_Call) TypedReturns(resp *http.Response, err error) *httpClientMockDo_Call {
	c.Return(resp, err)
	return c
}
```

`TypedReturns` has the same signature as the real method. Change `Do`'s return type, regenerate, and the compiler tells you what broke. I've caught several bugs this way that would have shipped otherwise.

#### When to Use What

- **Simple interfaces (1-2 methods)**: Hand-written mocks are fine
- **Large interfaces or many mocks**: Mocktail saves hours
- **Frequently changing interfaces**: Mocktail's type safety is invaluable
- **Team projects**: Mocktail ensures consistency

Factory makes mocking possible. Mocktail removes the boilerplate.

---

## Real Scenarios Where This Matters

Some cases I've actually dealt with:

### Scenario 1: Multi-Tenant API

You're building a SaaS platform. Different tenants have different rate limits, different API endpoints, and different authentication tokens.

**With Singleton:**
```go
// Uh oh. ONE client for ALL tenants?
client := httpclient.GetClient()
// How do we set different headers per tenant?
// How do we route to different endpoints?
// Answer: We don't. Not easily.
```

**With Factory:**
```go
// Extended config for multi-tenant scenarios
// (extends our base ClientConfig with tenant-specific fields)
type TenantClientConfig struct {
	httpclient.ClientConfig
	BaseURL string
	Headers map[string]string
}

// Each tenant gets its own configured client!
func NewTenantClient(tenant Tenant) httpclient.HTTPClient {
	cfg := TenantClientConfig{
		ClientConfig: httpclient.ClientConfig{
			Timeout:             tenant.TimeoutConfig,
			MaxIdleConns:        100,
			MaxIdleConnsPerHost: 10,
			IdleConnTimeout:     90 * time.Second,
		},
		BaseURL: tenant.APIEndpoint,
		Headers: map[string]string{
			"Authorization": "Bearer " + tenant.APIToken,
			"X-Tenant-ID":   tenant.ID,
		},
	}
	// In practice, you'd use cfg.BaseURL and cfg.Headers
	// in a custom RoundTripper or wrapper
	return httpclient.NewClient(cfg.ClientConfig)
}

// In your handler factory
func NewUserHandler(tenant Tenant) *UserHandler {
	client := NewTenantClient(tenant)
	return &UserHandler{client: client}
}
```

### Scenario 2: Rate-Limited External API

You're calling an external API with rate limits. You need different backoff strategies for different endpoints.

**With Singleton:**
```go
// One rate limiter for the entire application?
// What if /users allows 100 req/s but /payments only allows 10 req/s?
client := httpclient.GetClient()
// You'd need to wrap EVERY call with custom rate limiting logic.
// That's not encapsulation, that's a nightmare.
```

**With Factory:**
```go
// Rate-limited client factory
func NewRateLimitedClient(rps int, burst int) httpclient.HTTPClient {
	limiter := rate.NewLimiter(rate.Limit(rps), burst)
	baseClient := httpclient.NewClient(httpclient.DefaultConfig())

	return &RateLimitedClient{
		client:  baseClient,
		limiter: limiter,
	}
}

// Create specialized clients
usersClient := NewRateLimitedClient(100, 150)    // High throughput
paymentsClient := NewRateLimitedClient(10, 15)   // Conservative

userHandler := NewUserHandler(usersClient)
paymentHandler := NewPaymentHandler(paymentsClient)
```

### Scenario 3: Feature Flags

You want to gradually roll out a new HTTP/2 transport.

**With Singleton:**
```go
// Change the singleton = change for EVERYONE
// No gradual rollout, no A/B testing, no easy rollback
// Hope your prayers are answered!
```

**With Factory:**
```go
import "golang.org/x/net/http2" // Required for HTTP/2 support

func NewClientWithHTTP2(cfg ClientConfig, enableHTTP2 bool) httpclient.HTTPClient {
	transport := &http.Transport{
		MaxIdleConns:        cfg.MaxIdleConns,
		MaxIdleConnsPerHost: cfg.MaxIdleConnsPerHost,
		IdleConnTimeout:     cfg.IdleConnTimeout,
	}

	if enableHTTP2 {
		// Configure transport for HTTP/2 support
		http2.ConfigureTransport(transport)
	}

	return &http.Client{
		Timeout:   cfg.Timeout,
		Transport: transport,
	}
}

// In your main.go or DI container
func setupClients(featureFlags FeatureFlags, userID string, config ClientConfig) httpclient.HTTPClient {
	if featureFlags.IsEnabled("http2_rollout", userID) {
		return NewClientWithHTTP2(config, true)
	}
	return NewClientWithHTTP2(config, false)
}
```

---

## The Trade-offs

Here's how they compare:

| Aspect | Singleton | Factory |
|--------|-----------|---------|
| **Testability** | Hard to mock, no parallel tests | Easy mocks, parallel-safe |
| **Flexibility** | One config for all | Different configs per use case |
| **Concurrency** | Shared state = potential races | Isolated instances = safe |
| **Dependencies** | Hidden (global access) | Explicit (injected) |
| **Multi-tenancy** | Very difficult | Natural fit |
| **Feature flags** | All or nothing | Per-instance control |
| **Debugging** | "Which code path set this?" | Clear dependency chain |

### When Singleton Actually Makes Sense

To be fair, Singleton isn't always wrong:

- **True singletons**: There really can only be one (e.g., a process-wide metrics registry)
- **Immutable configuration**: Loaded once at startup, never changed
- **Resource pools**: Connection pools where you explicitly WANT sharing
- **Logging**: Usually fine as a singleton (but consider structured logging with context)

The question I ask myself: "Will I ever need different behavior in different contexts?" If there's any chance the answer is yes, Factory. If it's truly global and immutable, Singleton might be fine.

In practice, I default to Factory and only reach for Singleton when I have a specific reason.

```go
// Default approach: Factory + Dependency Injection
type Server struct {
	userHandler    *UserHandler
	paymentHandler *PaymentHandler
	healthHandler  *HealthHandler
}

func NewServer(cfg Config) *Server {
	// Create clients with factory functions
	apiClient := httpclient.NewClient(cfg.APIClientConfig)
	paymentClient := httpclient.NewClient(cfg.PaymentClientConfig)

	return &Server{
		userHandler:    NewUserHandler(apiClient),
		paymentHandler: NewPaymentHandler(paymentClient),
		healthHandler:  NewHealthHandler(),
	}
}

func main() {
	cfg := LoadConfig()
	server := NewServer(cfg)
	http.ListenAndServe(":8080", server.Router())
}
```

---

## Migrating from Singleton to Factory

If you're stuck with a singleton-heavy codebase (I've been there), here's how to migrate incrementally:

### Step 1: Define an Interface

```go
// Before: direct use of *http.Client
// After: interface that *http.Client already implements
type HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
}
```

### Step 2: Create a Factory Function

```go
func NewHTTPClient(cfg Config) HTTPClient {
	return &http.Client{
		Timeout: cfg.Timeout,
		// ... configuration
	}
}
```

### Step 3: Update Handlers to Accept Dependencies

```go
// Before
type UserHandler struct{}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	client := httpclient.GetClient() // Singleton!
	// ...
}

// After
type UserHandler struct {
	client HTTPClient
}

func NewUserHandler(client HTTPClient) *UserHandler {
	return &UserHandler{client: client}
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	// Use h.client instead of global
}
```

### Step 4: Wire Everything in main()

```go
func main() {
	client := httpclient.NewHTTPClient(config)
	userHandler := api.NewUserHandler(client)
	// ... register routes
}
```

---

## Interactive Example

If you want to play with the concepts, here's a simplified version:

```go
import "fmt"

// HTTPClient interface - the contract
type HTTPClient interface {
	Get(url string) string
}

// RealClient - production implementation
type RealClient struct{}

func (c RealClient) Get(url string) string {
	return "Real response from: " + url
}

// MockClient - test implementation
type MockClient struct {
	Response string
}

func (c MockClient) Get(url string) string {
	return c.Response
}

// UserService depends on HTTPClient interface
type UserService struct {
	client HTTPClient
}

func (s UserService) FetchUser(id string) string {
	return s.client.Get("https://api.example.com/users/" + id)
}

func main() {
	// Production: use real client
	realService := UserService{client: RealClient{}}
	fmt.Println("Production:", realService.FetchUser("123"))

	// Testing: use mock client
	mockService := UserService{client: MockClient{Response: "Mocked User Data"}}
	fmt.Println("Test:", mockService.FetchUser("123"))
}
```

`UserService` doesn't care which client it gets. That's the point.

---

## Production Hardening

Some things I've learned from production incidents:

### 1. Always Limit Response Body Size

A malicious or misbehaving upstream API could send gigabytes of data. Protect yourself:

```go
const maxResponseBodySize = 1 << 20 // 1MB

// Always wrap response body reading
limitedBody := io.LimitReader(resp.Body, maxResponseBodySize)
json.NewDecoder(limitedBody).Decode(&result)
```

### 2. Propagate Context for Cancellation

If a client disconnects, you don't want to waste resources completing their request:

```go
// Use the incoming request's context
req, err := http.NewRequestWithContext(r.Context(), http.MethodGet, url, nil)
```

### 3. Drain Response Bodies for Connection Reuse

HTTP/1.1 connections can only be reused if the response body is fully read:

```go
defer func() {
	// Drain remaining body to allow connection reuse
	io.Copy(io.Discard, io.LimitReader(resp.Body, maxResponseBodySize))
	resp.Body.Close()
}()
```

### 4. Check Status Codes Before Processing

Don't waste CPU decoding error responses as valid data:

```go
if resp.StatusCode != http.StatusOK {
	io.Copy(io.Discard, io.LimitReader(resp.Body, maxResponseBodySize))
	return nil, fmt.Errorf("upstream API returned %d", resp.StatusCode)
}
```

### 5. Set Content-Type Headers

Be explicit about what you're returning:

```go
w.Header().Set("Content-Type", "application/json")
json.NewEncoder(w).Encode(result)
```

---

## Wrapping Up

Factory adds some boilerplate. About 40-50 lines for a typical HTTP client setup. In exchange, you get testable code, flexible configuration, and fewer 3 AM incidents.

Singleton isn't evil. It's just overused. Most HTTP clients don't need to be singletons, and the ones that do are rarer than you'd think.

Next time you're about to write `var instance *http.Client` with `sync.Once`, ask yourself if you'll ever need to mock it, configure it differently, or debug it in production. If the answer to any of those is "maybe," use a factory.

---

*If you spot a bug in the examples or want to argue that Singleton is fine, find me on [GitHub](https://github.com/tommoulard).*

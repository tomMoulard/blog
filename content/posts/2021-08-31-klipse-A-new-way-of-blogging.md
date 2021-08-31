---
title: "Klipse, a new way of blogging"
date: 2021-08-31T13:00:00+01:00
author: Tom Moulard
url: /klipse-blogging
draft: false
type: post
tags:
  - blogging
  - klipse
  - programming
categories:
  - tutoriel
---

For a modern tech blogging framework, a live coding experience is quasi necessary.

> [Klipse](https://github.com/viebel/klipse) is a JavaScript plugin for embedding interactive code snippets in tech blogs.

To make this easy, you add a small library to your blog front end dependency, and voilà, you have your `<code></code>` live executing in the browser.
As a bonus, your code can no be edited directly in the `<code></code>` tags.

Go check out [this blog post](https://blog.klipse.tech/golang/2021/08/29/blog-go.html) if you want to have more information about Klipse!

# Klipsify your blogging framework
To integrate the klipse plugin on a blog, you have to follow 3 simple steps.

 1) Make sure you have `<!DOCTYPE html>` at the top of your html file and `<meta charset="utf-8">` right after your `<head>` (It is required to display properly elements used by Klipse.)

 2) Add css and custom configuration somewhere in the page (it could be in the `<head>` or in the `<body>`) before the `<script>` element of step #3.
The selector keys are per language (you'll find in [GitHub](https://github.com/viebel/klipse#configuration) a list of supported languages) and the value are the CSS selector of the elements that you want to klipsify.

```html
<link rel="stylesheet" type="text/css" href="https://storage.googleapis.com/app.klipse.tech/css/codemirror.css">

<script>
    window.klipse_settings = {
        selector_golang: '.language-klipse-eval-js', // css selector for the html elements you want to klipsify
    };
</script>
```

3) Add the JavaScript tag at the end of the body tag :
```html
<!-- ... -->
<body>
    <!-- ... -->
    <script src="https://storage.googleapis.com/app.klipse.tech/plugin_prod/js/klipse_plugin.min.js"></script>
</body>
```

# Write some code
Now that you have installed Klipse on your blog, it remains to add some code to a blog post.

Add this code snippet to try it on:
```go
import "fmt"

func main() {
  fmt.Println("Hello World! Klipse is so much fun !")
}
```

As you can see, this code is now live and interactive.

Feel free to modify it to your own liking!

# Conclusion
Live and interactive coding was a long dream of mine when creating this blog.

Klipse made this dream super easy to integrate on my blog!

This post was inspired by [@viebel](https://github.com/viebel).

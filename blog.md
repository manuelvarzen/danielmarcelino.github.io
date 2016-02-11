---
layout: page
title: Blog Posts
css: "/css/index.css"
permalink: /blog/
---

<ul class="posts">
  {% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.date | date: "%Y-%m-%d" }} - {{ post.title }}</a></li>
  {% endfor %}
</ul>
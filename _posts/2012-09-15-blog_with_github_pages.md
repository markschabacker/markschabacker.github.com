---
layout: post
title: "Hosting a Blog with GitHub Pages"
---

I have put off blogging for entirely too long.  It's time to check off the "Blog!" task that has been clogging the top of my [Remember the Milk](http://www.rememberthemilk.com) list for what seems like an eternity.  Here are the steps I followed to set up the blog that you're reading right now.

#### 1. Purchase a Domain Name ####
[DNSimple](http://www.dnsimple.com) makes it very easy to configure the various services that you are going to want to set up for your shiny new domain.  Sign up via my [referral link](https://dnsimple.com/r/1f12067ef76126) and we both get a month free!

* If you decide not to use DNSimple, expect to jump through a few more hoops when setting up DNS in the steps below

#### 2. Create a GitHub Repo for Your Blog ####
[GitHub](https://www.github.com) will graciously host a User/Organization or Project page for completely free.  You just need to create a repo in a specific format and GitHub will do all the heavy lifting.

1. Create a new repository for your page.  The repository name must follow [a very specific naming scheme](https://help.github.com/articles/user-organization-and-project-pages).
    * My repo will be called `markschabacker.github.com` since my github username is [markschabacker](https://github.com/markschabacker)
    * Obviously the repo needs to be public

2. Clone the repository onto your local machine so you can do some work:

        cd ~/blog_parent_directory
        git clone git@github.com:yourname/yourname.github.com.git
        cd yourname.github.com

3. Add a dummy `index.html` to test all this out
    
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>Smoke Test</title>
          </head>
          <body>
            Smoke Test
          </body>
        </html>

4. Push it all to GitHub

        git add .
        git commit -m "Smoke Test"
        git push origin master
    After waiting a little bit, you should be able to view your (very simple) page at http://yourname.github.com .  The GitHub docs say this could take up to 10 minutes.

5. Point your domain to your GitHub Pages site
Using DNSimple, this is as easy as: 
    1. Navigate to your domain
    2. Scroll down to "GitHub Pages"
    3. Click "Add"

6. Create a CNAME record in your repository

        echo "www.yourdomainname.com" > CNAME
        git add .
        git commit -m "Add CNAME to gh-pages"
        git push origin master
    Again, it may take a little while for GitHub to process these changes.  Subsequent changes will happen much faster.  Once updated, you should see your "Smoke Test" page at www.yourdomainname.com.  

#### 3. Use Jekyll to Generate Your Blog ####
Since GitHub Pages only hosts static files, we can't use a typical blog engine that stores our posts in a relational database.  Instead, we're going to write entries in [Markdown](http://daringfireball.net/projects/markdown/) and use [Jekyll](https://github.com/mojombo/jekyll) to generate the HTML for our site.  To add a new post, we will just: 

1. Write the new post in a new Markdown formatted file in the `_posts` folder
2. Commit the new post to our git repository
3. Push the local repo to GitHub.

We're trading a little bit more work up front to avoid a whole raft of server and database maintenance headaches.  

#### Installing Jekyll ####
Rather than pushing to GitHub to test every little change, it's easiest to set up Jekyll on our local machine for testing. I'm going to assume that you have a working ruby and [RubyGems](http://rubygems.org/) install (setting these up is beyond the scope of this post).  Once you have ruby and RubyGems set up, installing Jekyll is as easy as 

    gem install jekyll

Jekyll includes a web server for your debugging pleasure.  Let's test that out now

    jekyll --server

If everything is up and running, you should be able to view your "Smoke Test" page by navigating to http://localhost:4000 .  We're not actually doing anything with Jekyll here but it's still a useful test.  

#### Generate an Interesting Structure with Jekyll ####
Basically, Jekyll combines source and layout files that have been arranged [in a well defined structure](https://github.com/mojombo/jekyll/wiki/usage) into the plain HTML that will make up your blog. We're going to start off by working through a very short example.   

1. Create a `_config.yml` file

        exclude: 
        
        permalink: /blog/:year/:month/:day/:title/

2. Add some test blog posts in the _posts folder

`_posts/2012-09-14-my-first-post.md`

```
---
layout: post
title: "First Post!"
---

This is the first post
```

`_posts/2012-09-15-back-for-more.md`

```
---
layout: post
title: "Back For More"
---

This is the second post
```

`_layouts/default.html`

```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{% raw %}{{ page.title }}{% endraw %}</title>
  </head>
  <body>
    {% raw %}{{ content }}{% endraw %}
  </body>
</html>
```

`index.html`

```
---
layout: default
title: Blog Example
---
    <h1>{{ "{{ page.title " }}}}</h1>
    {{ "{% for post in site.posts " }}%}
      <div>
        <p><h2>{{ "{{ post.title " }}}}</h2>{{  "{{ post.date | date_to_string " }}}}</p>
        <p>{{ "{{ post.content " }}}}</p>
      </div>
    {{ "{% endfor " }}%}
```

Generate the site and browse to http://localhost:4000

        jekyll --server

At this point you should see an extremely ugly web page containing your two blog posts.  It's not very existing, but everything is working. You can see an example in my git repo [(here)](https://github.com/markschabacker/markschabacker.github.com/tree/rough_demo). 

#### 4. Make Things Pretty ####
The layout from the last step is obviously a bit lacking.  Let's use the [Twitter Bootstrap](http://twitter.github.com/bootstrap/) to make things a bit prettier.  At this point in the tutorial, I'm going to switch to a more "show and tell" type style.  You can find source for the previous example gussied up [here](https://github.com/markschabacker/markschabacker.github.com/tree/rough_demo_skinned).

#### Summary ####
We've set up a very simple blog and laid the groundwork for some more advanced features in the future but there's still quite a bit more work to be done.  Follow along with my changes [here](https://github.com/markschabacker/markschabacker.github.com).  

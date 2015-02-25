---
layout: post
title: "Code Smells: #region and Outlining"
---

I recently set up a new installation of Visual Studio and was reminded of a pair of .NET code smells: the [`#region` directive](https://msdn.microsoft.com/en-us/library/9a1ybwek.aspx) and its good friend [code outlining](https://msdn.microsoft.com/en-us/library/vstudio/td6a5x4s\(v=vs.120\).aspx).

### #region Directive

MSDN describes the `#region` directive [as follows](https://msdn.microsoft.com/en-us/library/9a1ybwek.aspx#introduction):
> `#region` lets you specify a block of code that you can expand or collapse when using the outlining feature of the Visual Studio Code Editor. In longer code files, it is convenient to be able to collapse or hide one or more regions so that you can focus on the part of the file that you are currently working on. 

### Code Outlining

Visual Studio's code outlining is a wonder to behold.  It allows the user to fluidly collapse code structures on a class, method, `#region`, etc boundary:

<div class="text-center">
<img src="/images/code_smell_expand_collapse.gif" alt="Outlining Example">
</div>

## First Impressions

The first time I tried out the cold folding and `#region` combo, I thought it was great.  I was using a language feature to organize my code, encapsulate shared logic, and communicate with my team members, right?  On top of that, I could hide all the unrelated code in a file when when I was working in another section of the same file.  Wins all around.

## Further Analysis

I continued down this happy path for quite a while.  However, I started to notice that my code wasn't very easy to maintain even though I thought it was wonderfully organized.  I had trouble reusing components because my classes were enormous.  I had trouble getting my classes under test because they performed so many responsibilities.  Even worse, it was hard for other developers to understand everything that my classes were doing.

It turns out that I had missed a major code smell in my `#region` frenzy.  Instead of wrapping code in `#region` tags, I should have used `#region` boundaries as guidelines to break related code into new classes.  I had the right idea but I was encapsulating too weakly.  I let Visual Studio hide complexity and lull me into violating the Single Responsibility principle.

## No More Regions

After seeing the error in my ways, I'd rather not see code outlining in Visual Studio at all.  It's fairly easy to disable the feature by toggling a poorly named configuration option.  Simply uncheck the option here:

    Tools -> Options -> Text Editor -> C# -> Advanced -> Enter outlining mode when files open

<div class="text-center">
<img src="/images/code_smell_outlining_setting.png" alt="Outlining Setting">
</div>

With this setting enabled, you will never see a code outlining expand/collapse icon in the line number gutter.  From now on, you can use the `#region` directive as it should be used: to warn that your class has taken on too much responsibility and should be broken up.


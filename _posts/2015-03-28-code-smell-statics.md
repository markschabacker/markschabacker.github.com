---
layout: post
title: "C# Code Smell: Static Classes and Methods"
---

A colleague and I were recently griping about a popular Visual Studio refactoring tool and our strong dislike for some of the tool's most common recommendations.  Specifically, the tool in question frequently recommends that entire classes and/or class members should be made static.

The performance improvement for instance to static refactoring is almost never enough to justify this change.  Specifically, the following questions are useful when considering this type of refactoring:

- Will I ever have the need to extract an interface for this class's behavior?
- Will I ever need to extend this functionality?  Perhaps in a subclass?
- Will I ever need to stub or mock this behavior?

If "yes" is the answer to any of these questions, then an instance to static refactoring is probably going to make things difficult for myself or another developer in the future.  I think of statics this way: only one copy of a static will exist in both a running program and for the lifetime of the source code.  If there's any reason that a potential static would need to change either at runtime or compile time, then it probably should not be static.  The only time I'm not overly concerned about static classes is in the case of extension methods, but that discussion is probably worth a whole other post.

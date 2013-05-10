---
layout: post
title: "Using JMeter with ASP.NET WebForms Authentication"
---

I recently ran into a situation where I needed to quickly simulate a large number of concurrent users running through a very simple path in an ASP.NET WebForms application.  [Apache JMeter](http://jmeter.apache.org/) quickly emerged as the best tool for the job.  The [Recording Proxy](http://jmeter.apache.org/usermanual/jmeter_proxy_step_by_step.pdf) made creating the Test Plan a breeze.  I was impressed and optimistic as I let the tool loose on the site but disappointed when every request returned a redirect (302) to the login page. (View request/response results in a "View Results Tree" element in your Thread Group)

``` html
<html><head><title>Object moved</title></head><body>
<h2>Object moved to <a href="%2fwebFormsApp%2fweb%2fauthorization%2fAccess.aspx">here</a>.</h2>
</body></html>
```

After a bit of research, it became apparent that JMeter was running into issues with VIEWSTATE, which is one of the workarounds ASP.NET WebForms uses to make HTTP appear to be stateful.  Essentially, JMeter is sending a stale value for VIEWSTATE since it is replaying the HTTP requests in the test plan.  We need to extract the VIEWSTATE from each response and re-include that value on our requests or ASP.NET WebForms will redirect to the login page.  We will do that with two Regular Expression Extractors.

### Regular Expression Extractors
Our first regular expression extractor will grab the page's VIEWSTATE element and store it in the JMeter `viewState` variable.  Add a new Regular Expression Extractor in JMeter by:

1. Right click on your Thread Group
2. Choose Add -> Post Processors -> Regular Expression Extractor
3. Configure as follows
    - Reference Name: `viewState`
    - Regular Expression: `name="__VIEWSTATE" id="__VIEWSTATE" value="(.+?)"`
    - Template: `$1$`
    - Math No: `1`
    - Default Value: `ERROR`

![VIEWSTATE Regular Expression Extractor](/images/regular_expression_extractor_viewstate.jpg)

We also need to include a regex extractor that stores the EVENTVALIDATION element in the `eventValidation` variable.  Again:

1. Right click on your Thread Group
2. Choose Add -> Post Processors -> Regular Expression Extractor
3. Configure as follows
    - Reference Name: `eventValidation`
    - Regular Expression: `name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="(.+?)"`
    - Template: `$1$`
    - Math No: `1`
    - Default Value: `ERROR`

![EVENTVALIDATION Regular Expression Extractor](/images/regular_expression_extractor_eventvalidation.jpg)

#### Using the Extracted Values
Now that we have populated the `viewState` and `eventValidation` values, we need to include them when we POST to our application.  In my run, this only happened on the login page.

1. Select your login page POST in the Test Plan's Recording Controller
2. Set the `__VIEWSTATE` parameter to `${viewState}`
3. Set the `__EVENTVALIDATION` parameter to `${eventValidation}`

![Login POST Configuration](/images/login_post_configuration.jpg)

### HTTP Cookie Manager
If you run your test plan now, you will see that it is still not working.  This is because ASP.NET WebForms uses a cookie to store the login session.  We can solve this with JMeter's "HTTP Cookie Manager".

1. Right click on your Thread Group
2. Choose Add -> Config Element -> HTTP Cookie Manager

Finally, run your Test Plan.  You should see that your WebForms application returns the correct responses to JMeter's requests.  If not, double check that you are using the `viewState` and `eventValidation` variables in your login page POST (or any other post, for that matter) and that you have added the Cookie Manager.

### Bonus - Parameterize Credentials Across Threads
Application performance for multiple concurrent logins with the same user is probably not a very interesting test case for your system.  Luckily, it is extremely easy to parameterize login credentials for JMeter threads with a "CSV Data Set Config" element.

#### Store Credentials in CSV File
1. Create a text file named `credentials.csv` in the same directory as your Test Plan `.jmx` file
2. Populate `credentials.csv` with the login credentials you want to use (mind extra spaces)

```
login\_1,password\_1
login\_2,password\_2
login\_3,password\_3
```

#### Add CSV Data Set Config
1. Select your Thread Group
2. Choose Add -> Config Element -> CSV Data Set Config
3. Configure as follows
    - Filename: `credentials.csv`
    - Variable Names: `username,password`

![CSV Data Set Config](/images/csv_data_set_config.jpg)

#### Use Variable Credentials in Login Post
1. Select your login page POST in the Test Plan's Recording Controller
2. Configure as follows
    - \<Your Login Element ID\> : `${username}`
    - \<Your Password Element ID\> : `${password}`

![Login POST Configuration with username, password Variables](/images/login_post_configuration_credentials.jpg)

Now the threads in your Test Plan will cycle through the credentials specified in your CSV.

##### Acknowledgements
The following articles were extremely helpful in figuring all of this out:

- [Technically Works: Load Testing SharePoint (MOSS) Sites with JMeter](http://blog.technicallyworks.com/2009/06/load-testing-aspnet-with-jmeter.html)
- [Technically Works: Load Testing ASP.NET Sites with JMeter](http://blog.technicallyworks.com/2009/06/load-testing-aspnet-sites-with-jmeter.html)
- [JMeter Tips: Tip #7: How to add cookie support to your Test Plan](http://jmeter-tips.blogspot.com/2010/02/tip-7-how-to-add-cookies-support-to.html)


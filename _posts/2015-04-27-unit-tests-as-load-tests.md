---
layout: post
title: "Unit Test Transactions in Visual Studio Load Tests"
---

Visual Studio Ultimate provides extremely robust performance and load testing capabilities if you have the license for it.  One of my favorite capabilities is the ability to use existing unit tests as load tests.  This is a very nice way to leverage existing code to provide a fairly robust load test suite.

Unfortunately, load test results from the converted unit tests are extremely course since they report on unit test execution time and can't hook into underlying HTTP calls.  However, the [`TestContext.BeginTimer`](https://msdn.microsoft.com/en-us/library/microsoft.visualstudio.testtools.unittesting.testcontext.begintimer.aspx) method allows the load test runner to record more granular transactions in converted unit tests.

<div class="text-center">
<img src="/images/transactions_diff.png" alt="Before and After Transactions">
</div>

There is a fairly large gotcha in that the `BeginTimer` method will throw an exception if called outside a load test.  However, the test execution context is readily available in the unit test's `TestContext` property.  The detection code also presents a nice opportunity to wrap the transaction logging code in an `IDisposable` interface which provides a nice, clean API for the functionality.

The following example wraps this up to show unit test code that produces granular transaction results when executed as a load test.

#### Unit Test

``` csharp
[TestMethod]
public void TestFooBar()
{
    var fooBar = new FooBar();

    using (this.LogTransaction("foo"))
    {
        fooBar.foo();
    }

    using (this.LogTransaction("bar"))
    {
        var barResults = fooBar.bar();
        Assert.IsNotNull(barResults, "barResults should not be null");
    }
}
```

#### Transaction Logging Helper

``` csharp
protected ITestTransactionTimer LogTransaction(string transactionName)
{
    if ((null == this.TestContext) || !this.TestContext.Properties.Contains("$LoadTestUserContext"))
    {
        return new NoOpTestTransactionTimer();
    }
    return new TestTransactionTimer(this.TestContext, transactionName);
}
```

#### Transaction Timer Interface and Implementations
``` csharp
public interface ITestTransactionTimer : IDisposable { }

public class TestTransactionTimer : ITestTransactionTimer
{
    public TestContext TestContext { get; private set; }
    public string TransactionName { get; private set; }

    public TestTransactionTimer(TestContext testContext, string transactionName)
    {
        this.TestContext = testContext;
        this.TransactionName = transactionName;

        this.TestContext.BeginTimer(this.TransactionName);
    }

    public void Dispose()
    {
        this.TestContext.EndTimer(this.TransactionName);
    }
}

public class NoOpTestTransactionTimer : ITestTransactionTimer
{
    public void Dispose() { }
}
```

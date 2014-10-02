# Swifty operations

!!! Very much work in progress !!!

Allows you to do cool stuff, such as:

```Swift
  NetworkOperation(url: url) |> JsonOperation()
```

or

```Swift
  NetworkOperation(url: imageUrl) |> DataToImageOperation() |> ImageResizeOperation(toSize: CGSize(width: 160, height: 120))
```

See the example project.

## TODO:

- Operation cancellation
- Some system for better code reuse
- Easy way of forking/merging operation chains
- Lots of cool operations to chain together

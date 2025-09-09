# Higher Order Component Refactoring Process

STARTER_CHARACTER = 🟣

**ALWAYS** ask the user one question at a time and wait for a response.

**ALWAYS** confirm file names and locations if unsure.

**NEVER** make changes to Test code in this process.

This process is for refactoring React components by extracting data loading complexity to a Higher Order Component.

## Target

### Problem definition

Let's refactor this component:

```tsx

// modules/Products/ui/EditProduct.tsx

export function EditProduct() {
  const { id } = useParams<{ id: string }>()

  const { data: product } = useProductQuery(
    { id: id! },
    { skip: !id },
  )

  if (!id || !product) {
    return null
  }

  // Code using id or product here

  return (
    // Code using id or product here
  )
}
```

Problematic parts are due to `id` and `product` being used before they are guaranteed to be available. Because of this we have to write `{ skip: !id }` and `if (!id || !product) {`.

### Removing the `useParams` hook

First step to solve this is to make `id` a required prop.

```tsx

// modules/Products/ui/EditProduct.tsx

interface EditProductProps {
  id: string
}

function EditProduct({id}: EditProductProps) {
    const { data: product } = useProductQuery({ id })

  if (!product) {
    return null
  }

  // Code using product here

  return (
    // Code using product here
  )
}

export default withIdFromParams(EditProduct)

// shared/lib/withIdFromParams.tsx

export function withIdFromParams<P>(
  Wrapped: ComponentType<P & { id: string }>,
): ComponentType<P> {
  return function WithIdFromParams(props: P) {
    const { id } = useParams<{ id: string }>()

    if (!id) {
      return null
    }

    return (
      <Wrapped
        {...props}
        id={id}
      />
    )
  }
}
```

### Removing query hook

Next step is to remove the `useProductQuery` hook. We will be reusing the `withIdFromParams` Higher Order Component from the previous step.

```tsx

// modules/Products/ui/EditProduct.tsx

interface EditProductProps {
  product: Product
}

function EditProduct({product}: EditProductProps) {
  // Code using product here

  return (
    // Code using product here
  )
}

export default withProduct(EditProduct)

// modules/Products/lib/withProduct.tsx

export function withProduct(
  Wrapped: ComponentType<{ product: Product }>,
): ComponentType {
  function WithProduct({ id }: { id: string }) {
    const { data: product } = useProductQuery({ id })

    if (!product) {
      return null
    }

    return <Wrapped product={product} />
  }

  return withIdFromParams(WithProduct)
}
```

## Setup

Confirm the relevant test file exists and its location before starting. If there is no test file, stop the process and notify user.

## Steps

1. Ensure all tests pass with `yarn test`
2. Search for an existing Higher Order Component that can be used to refactor the component.
3. If no such component is found, create one. It has to be as simple as possible.
4. Remove the data loading logic from the component
5. Call the Higher Order Component.
6. Ensure all tests pass after the change.
7. Commit each successful refactor with the message format: `refactor: <refactoring>`.
8. Provide a status update after each refactor.

**Note**: if a refactor fails three times or no further refactoring is found, pause and check with the user.

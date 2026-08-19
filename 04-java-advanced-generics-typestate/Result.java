import java.util.function.Function;

// Result<T, E> — a sum type for computations that may fail.
//
//   Result<T, E> = Ok<T, E>(value) | Err<T, E>(error)
//
// BOTH channels are typed. The success side carries a T; the failure side
// carries an E, which in this repository is PaymentError — itself a sum of
// products. Scala spells this Either[E, T]; Rust spells it Result<T, E>.
//
// To USE the result you must handle both variants — that IS ∨-elimination
// (Gentzen's ∨E rule):
//
//   switch (result) {
//     case Result.Ok<T, E>  ok  -> use(ok.value());
//     case Result.Err<T, E> err -> handle(err.error());
//   }
//
// No getValue(): unsafe extraction breaks the guarantee. Only flatMap, map and
// an exhaustive switch are safe.
public sealed interface Result<T, E> {
    record Ok<T, E>(T value) implements Result<T, E> {
        @Override public String toString() { return "Ok(" + value + ")"; }
    }
    record Err<T, E>(E error) implements Result<T, E> {
        @Override public String toString() { return "Err(" + error + ")"; }
    }

    static <T, E> Result<T, E> ok(T value)  { return new Ok<>(value); }
    static <T, E> Result<T, E> err(E error) { return new Err<>(error); }

    default <U> Result<U, E> flatMap(Function<T, Result<U, E>> f) {
        return this instanceof Ok<T, E> ok ? f.apply(ok.value()) : Result.err(((Err<T, E>) this).error());
    }

    default <U> Result<U, E> map(Function<T, U> f) {
        return flatMap(v -> Result.ok(f.apply(v)));
    }
}

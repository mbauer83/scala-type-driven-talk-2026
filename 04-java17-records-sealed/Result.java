import java.util.function.Function;

// Stage 04: Result<T> — a canonical sum type for computations that may fail.
//
// Result<T> = Ok<T>(value) | Err(message)
//
// This is a sum type (disjunction, A ∨ B). To USE the result, you must
// handle both variants — that IS ∨-elimination (Gentzen's ∨E rule):
//
//   switch (result) {
//     case Result.Ok<T>  ok  -> use(ok.value());    // proof that A holds
//     case Result.Err<T> err -> handle(err.message()); // proof that B holds
//   }
//
// No getValue(): unsafe extraction breaks the guarantee. If you call getValue()
// on an Err, you get a runtime exception — the OR has not been fully eliminated.
// Only flatMap/map/exhaustive switch are safe.

public sealed interface Result<T> permits Result.Ok, Result.Err {
    record Ok<T>(T value) implements Result<T> {
        @Override public String toString() { return "Ok(" + value + ")"; }
    }
    record Err<T>(String message) implements Result<T> {
        @Override public String toString() { return "Err(" + message + ")"; }
    }

    static <T> Result<T> ok(T value)        { return new Ok<>(value); }
    static <T> Result<T> err(String message) { return new Err<>(message); }

    default <U> Result<U> flatMap(Function<T, Result<U>> f) {
        return this instanceof Ok<T> ok ? f.apply(ok.value()) : Result.err(((Err<T>)this).message());
    }

    default <U> Result<U> map(Function<T, U> f) {
        return flatMap(v -> Result.ok(f.apply(v)));
    }
}

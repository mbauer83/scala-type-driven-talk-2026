import java.util.function.Function;

// Stage 02: Generics — Result<T> gives us a typed error container.
// No more mixing error strings with value types, no more unchecked casting.
// Err is fixed to String (not Err<E>) deliberately — talk keeps the focus on the value type T.

// @TODO: Check: did Java 5 really have "permits" and "sealed"? Those are later features no?
public sealed interface Result<T> permits Result.Ok, Result.Err {

    record Ok<T>(T value) implements Result<T> {
        @Override public String toString() { return "Ok(" + value + ")"; }
    }

    record Err<T>(String message) implements Result<T> {
        @Override public String toString() { return "Err(" + message + ")"; }
    }

    static <T> Result<T> ok(T value)        { return new Ok<>(value); }
    static <T> Result<T> err(String message) { return new Err<>(message); }

    default boolean isOk() { return this instanceof Ok; }

    @SuppressWarnings("unchecked")
    default T getValue() {
        if (this instanceof Ok<T> ok) return ok.value();
        throw new IllegalStateException("Called getValue() on Err: " + this);
    }

    default String getError() {
        if (this instanceof Err<T> err) return err.message();
        throw new IllegalStateException("Called getError() on Ok: " + this);
    }

    default <U> Result<U> map(Function<T, U> f) {
        return flatMap(v -> Result.ok(f.apply(v)));
    }

    default <U> Result<U> flatMap(Function<T, Result<U>> f) {
        if (this instanceof Ok<T> ok) return f.apply(ok.value());
        return Result.err(((Err<T>) this).message());
    }
}

import java.util.function.Function;
public sealed interface Result<T> permits Result.Ok, Result.Err {
    record Ok<T>(T value) implements Result<T> { public String toString() { return "Ok(" + value + ")"; } }
    record Err<T>(String message) implements Result<T> { public String toString() { return "Err(" + message + ")"; } }
    static <T> Result<T> ok(T value) { return new Ok<>(value); }
    static <T> Result<T> err(String msg) { return new Err<>(msg); }
    default boolean isOk() { return this instanceof Ok; }
    @SuppressWarnings("unchecked") default T getValue() { return ((Ok<T>)this).value(); }
    default <U> Result<U> flatMap(Function<T, Result<U>> f) {
        return this instanceof Ok<T> ok ? f.apply(ok.value()) : Result.err(((Err<T>)this).message());
    }
    default <U> Result<U> map(Function<T, U> f) { return flatMap(v -> Result.ok(f.apply(v))); }
}

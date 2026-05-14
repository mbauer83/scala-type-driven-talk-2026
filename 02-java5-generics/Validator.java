import java.util.function.Function;
import java.util.function.Predicate;

// Generic, composable validator. One definition; any domain type.
// Shows the power of parametric polymorphism: we write this once
// and reuse it for OrderLine, Order, and any future type.

@FunctionalInterface
public interface Validator<T> {

    Result<T> validate(T value);

    // Composition: first run this, then run next (if this passes).
    default Validator<T> andThen(Validator<T> next) {
        return value -> this.validate(value).flatMap(next::validate);
    }

    // Smart constructor: build a validator from a predicate and an error message.
    static <T> Validator<T> check(Predicate<T> predicate, String errorMessage) {
        return value -> predicate.test(value) ? Result.ok(value) : Result.err(errorMessage);
    }

    // Lift a transformation into a validator.
    static <T, U> Function<T, Result<U>> lift(Function<T, Result<U>> f) {
        return f;
    }
}

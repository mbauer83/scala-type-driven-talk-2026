import java.util.function.Predicate;

// Generic, composable validator. One definition; any domain type.
// Shows the power of parametric polymorphism: we write this once
// and reuse it for Integer, OrderLine, and any future type.
//
// Returns the valid value unchanged, or throws IllegalArgumentException.
// Composition via andThen: validators chain like function composition.

@FunctionalInterface
public interface Validator<T> {

    T validate(T value);

    // Composition: first run this, then run next (if this passes).
    default Validator<T> andThen(Validator<T> next) {
        return value -> next.validate(this.validate(value));
    }

    // Smart constructor: build a validator from a predicate and an error message.
    static <T> Validator<T> check(Predicate<T> predicate, String errorMessage) {
        return value -> {
            if (predicate.test(value)) return value;
            throw new IllegalArgumentException(errorMessage + ", got: " + value);
        };
    }
}

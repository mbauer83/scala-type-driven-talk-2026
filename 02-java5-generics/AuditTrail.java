import java.util.ArrayList;
import java.util.List;

// Stage 02: Generic audit trail — works for any event type.
// Still mutable; forgetting to append is still possible.

public class AuditTrail<E> {
    private final List<E> entries = new ArrayList<>();

    public void append(E entry) { entries.add(entry); }

    public List<E> getEntries() { return List.copyOf(entries); }

    @Override public String toString() { return entries.toString(); }

    // Convenience factory for String events
    public static AuditTrail<String> stringLog() { return new AuditTrail<>(); }
}

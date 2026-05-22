import java.util.ArrayList;
import java.util.List;

// Java 1–4 style: raw List without type parameter — no generics in this stage.
@SuppressWarnings({"rawtypes", "unchecked"})
public class AuditEntry {
    private final String event;
    private final String detail;

    public AuditEntry(String event, String detail) {
        this.event  = event;
        this.detail = detail;
    }

    public String getEvent()  { return event; }
    public String getDetail() { return detail; }

    @Override public String toString() {
        return event + ":" + detail;
    }

    // Simple mutable audit log — in this stage, forgetting to append is still possible.
    public static List newLog() { return new ArrayList(); }

    public static void append(List log, String event, String detail) {
        log.add(new AuditEntry(event, detail));
    }
}

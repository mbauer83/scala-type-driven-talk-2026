import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

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
    public static List<AuditEntry> newLog() { return new ArrayList<>(); }

    public static void append(List<AuditEntry> log, String event, String detail) {
        log.add(new AuditEntry(event, detail));
    }
}

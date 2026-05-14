import java.util.ArrayList; import java.util.List;
public class AuditTrail<E> {
    private final List<E> entries = new ArrayList<>();
    public void append(E entry) { entries.add(entry); }
    public List<E> getEntries() { return List.copyOf(entries); }
    public static AuditTrail<String> stringLog() { return new AuditTrail<>(); }
    public String toString() { return entries.toString(); }
}

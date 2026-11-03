import AppIntents
import SwiftUI
import TemoinCore
import WidgetKit

/// Lock Screen / Home Screen widget: one tap opens the app and starts filming.
struct RecordWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "io.github.temoin-app.temoin.record", provider: Provider()) { entry in
            RecordWidgetView()
                .widgetURL(QuickRecordLink(discreet: false).url(token: entry.token))
        }
        .configurationDisplayName("Filmer")
        .description("Ouvre Témoin et commence à filmer.")
        .supportedFamilies([.accessoryCircular, .systemSmall])
    }

    /// `token`: see WidgetToken. The app reloads the widgets when it creates it.
    struct Entry: TimelineEntry { let date: Date; let token: String? }

    struct Provider: TimelineProvider {
        func placeholder(in context: Context) -> Entry { Entry(date: .now, token: nil) }
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(Entry(date: .now, token: WidgetToken.forWidgets))
        }
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            completion(Timeline(entries: [Entry(date: .now, token: WidgetToken.forWidgets)], policy: .never))
        }
    }
}

/// Same, but the app opens on a dark screen: its interface never shows.
struct DiscreetRecordWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "io.github.temoin-app.temoin.record.discreet", provider: RecordWidget.Provider()) { entry in
            DiscreetRecordWidgetView()
                .widgetURL(QuickRecordLink(discreet: true).url(token: entry.token))
        }
        .configurationDisplayName("Écran noir")
        .description("Commence à filmer immédiatement, écran noir.")
        .supportedFamilies([.accessoryCircular, .systemSmall])
    }
}

struct DiscreetRecordWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "moon.fill").font(.title2)
            }
            .widgetBackground()
        default:
            VStack(spacing: 8) {
                Image(systemName: "moon.fill").font(.system(size: 40)).foregroundStyle(.white)
                Text("Écran noir").font(.headline)
            }
            .widgetBackground()
        }
    }
}

struct RecordWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "record.circle").font(.title)
            }
            .widgetBackground()
        default:
            VStack(spacing: 8) {
                Image(systemName: "record.circle.fill").font(.system(size: 44)).foregroundStyle(.red)
                Text("Filmer").font(.headline)
            }
            .widgetBackground()
        }
    }
}

private extension View {
    @ViewBuilder func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { Color.black }
        } else {
            background(Color.black)
        }
    }
}

/// Control Center / Lock Screen control and Action button (iOS 18).
@available(iOS 18.0, *)
struct RecordControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "io.github.temoin-app.temoin.control.record") {
            ControlWidgetButton(action: StartRecordingIntent()) {
                Label("Filmer", systemImage: "record.circle")
            }
        }
        .displayName("Filmer")
        .description("Ouvre Témoin et commence à filmer.")
    }
}

@available(iOS 18.0, *)
struct DiscreetRecordControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "io.github.temoin-app.temoin.control.record.discreet") {
            ControlWidgetButton(action: StartDiscreetRecordingIntent()) {
                Label("Écran noir", systemImage: "moon.fill")
            }
        }
        .displayName("Écran noir")
        .description("Commence à filmer immédiatement, écran noir.")
    }
}

@main
struct TemoinWidgetBundle: WidgetBundle {
    var body: some Widget {
        RecordWidget()
        DiscreetRecordWidget()
        if #available(iOS 18.0, *) {
            RecordControl()
            DiscreetRecordControl()
        }
    }
}

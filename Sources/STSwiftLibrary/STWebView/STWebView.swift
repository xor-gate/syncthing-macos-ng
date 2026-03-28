import SwiftUI
import WebKit

public struct STWebViewContainer: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    // 1. Create the NSView instance
    public func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    // 2. Update the view when state changes
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        // Check if we are already showing this URL to prevent redundant reloads
        if nsView.url == nil {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }

    // 3. The Coordinator handles WebKit delegates
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: STWebViewContainer

        public init(_ parent: STWebViewContainer) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            parent.isLoading = true
        }

        public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            parent.isLoading = false
        }
    }
}

public struct STWebView: View {
    @State private var isLoading = false
    public let url: URL

    public init(url: URL = URL(string: "http://127.0.0.1:8384")!) {
        self.url = url
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
            }
            
            STWebViewContainer(url: url, isLoading: $isLoading)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#!/usr/bin/env macruby

framework 'Cocoa'
framework 'WebKit'

class AppDelegate
  attr_reader :application, :main
  def initialize
    @application = NSApplication.sharedApplication
    @application.setDelegate self
    @main = MainWindow.new(640, 480)
    @main.delegate = self
  end
  def windowWillClose(*args)
    exit
  end
  def run
    @main.show
    @application.run
  end
end

class MainWindow
  attr_reader :win, :web_view
  def initialize(width, height)
    @win = NSWindow.alloc.initWithContentRect([0, 0, width, height],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false
    )
    @win.title = 'Application'
    @web_view = MainWebView.new(@win)
  end
  
  def delegate=(del)
    @win.setDelegate del
  end
  
  def show
    @win.display
    @win.orderFrontRegardless
  end  
end

class MainWebView
  def initialize(parent)
    @win = parent
    @view = WebView.alloc.initWithFrame([0,0,@win.frame.size.width, (@win.frame.size.height - 20)])
    @view.policyDelegate = self
    @win.contentView.addSubview @view
    @handler = RequestHandler.new
  end
  
  def html=(s)
    @view.mainFrame.loadHTMLString(s, baseURL: nil)
  end
  
  def webView(view,
      decidePolicyForNavigationAction: action,
      request: request,
      frame: frame,
      decisionListener: listener
    )
    a = {view: view, action: action, request: request, frame: frame, listener: listener}
    if request.URL.scheme =~ /^app/
      self.html = @handler.handle(request)
      false
    else
      listener.use
      true
    end
  end
end

class RequestHandler
  # take a url and return html
  
  def path(obj)
    %Q{file://#{Dir.pwd}/#{obj}}
  end
  
  def handle(r)
    <<-HTML
      <html>
        <style>
          body { background-color: black; color: white; }
          h1 { font-size: 48px; width: 100%; text-align: center; }
        </style>
        <body>
          <h1>#{r.URL.class.name}</h1>
          <img src="#{path('avatar.jpg')}">
        </body>
      </html>
    HTML
  end
end

if __FILE__ == $0
  app = AppDelegate.new
  app.main.web_view.html = <<-HTML
  <html>
    <style>
      body { background-color: black; color: white; }
      h1 { font-size: 48px; width: 100%; text-align: center; }
    </style>
    <body>
      <h1>Hello</h1>
      <a href="app:action/51212">click</a>
    </body>
  </html>
  HTML
  app.run
end
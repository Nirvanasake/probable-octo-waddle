class Zurl < Formula
  include Language::Python::Virtualenv

  desc "HTTP and WebSocket client worker with ZeroMQ interface"
  homepage "https://github.com/fanout/zurl"
  url "https://github.com/fanout/zurl/releases/download/v1.12.0/zurl-1.12.0.tar.bz2"
  sha256 "46d13ac60509a1566a4e3ad3eaed5262adf86eb5601ff892dba49affb0b63750"
  license "GPL-3.0-or-later"

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "e12d1eeabfc9d23cc6a0ef3058f46ae4102fd7df0d0fb7698aa088509aeacc61"
    sha256 cellar: :any,                 arm64_monterey: "1d0ffa790ce260a143e2e128320ce7855dc4d7876daadd5739fe8c7a1ee43845"
    sha256 cellar: :any,                 sonoma:         "2e6ac2a0fc30fc02b75d3220348ca9c15267d58de252a01b7f1c6484deb9cfe4"
    sha256 cellar: :any,                 ventura:        "a692e80b53a7275e0ab4f4dff81f0dc5737a4d2fa350fa4b9d6aff76d887d77f"
    sha256 cellar: :any,                 monterey:       "40652b39c795d9157fcd95c097791723af7ec011ad65ad959d07242fc6ed8143"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "62fc5497cd9456a5d5639870392b048f04d987f535ee167140950610ecb7a303"
  end

  depends_on "pkg-config" => :build
  depends_on "libcython" => :test
  depends_on "python-packaging" => :test
  depends_on "python-setuptools" => :test
  depends_on "python@3.12" => :test
  depends_on "qt"
  depends_on "zeromq"

  uses_from_macos "curl"

  on_linux do
    depends_on "openssl@3"
  end

  fails_with gcc: "5"

  resource "pyzmq" do
    url "https://files.pythonhosted.org/packages/3f/7c/69d31a75a3fe9bbab349de7935badac61396f22baf4ab53179a8d940d58e/pyzmq-25.1.1.tar.gz"
    sha256 "259c22485b71abacdfa8bf79720cd7bcf4b9d128b30ea554f01ae71fdbfdaa23"
  end

  def install
    args = ["--qtselect=#{Formula["qt"].version.major}"]
    args << "--extraconf=QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}" if OS.mac?

    system "./configure", "--prefix=#{prefix}", *args
    system "make"
    system "make", "install"
  end

  test do
    python3 = "python3.12"

    conffile = testpath/"zurl.conf"
    ipcfile = testpath/"zurl-req"
    runfile = testpath/"test.py"

    ENV.append_path "PYTHONPATH", Formula["libcython"].opt_libexec/Language::Python.site_packages(python3)
    venv = virtualenv_create(testpath/"vendor", python3)
    venv.pip_install(resource("pyzmq"), build_isolation: false)

    conffile.write(<<~EOS,
      [General]
      in_req_spec=ipc://#{ipcfile}
      defpolicy=allow
      timeout=10
    EOS
                  )

    port = free_port
    runfile.write(<<~EOS,
      import json
      import threading
      from http.server import BaseHTTPRequestHandler, HTTPServer
      import zmq
      class TestHandler(BaseHTTPRequestHandler):
        def do_GET(self):
          self.send_response(200)
          self.end_headers()
          self.wfile.write(b'test response\\n')
      def server_worker(c):
        server = HTTPServer(('', #{port}), TestHandler)
        c.acquire()
        c.notify()
        c.release()
        try:
          server.serve_forever()
        except:
          server.server_close()
      c = threading.Condition()
      c.acquire()
      server_thread = threading.Thread(target=server_worker, args=(c,))
      server_thread.daemon = True
      server_thread.start()
      c.wait()
      c.release()
      ctx = zmq.Context()
      sock = ctx.socket(zmq.REQ)
      sock.connect('ipc://#{ipcfile}')
      req = {'id': '1', 'method': 'GET', 'uri': 'http://localhost:#{port}/test'}
      sock.send_string('J' + json.dumps(req))
      poller = zmq.Poller()
      poller.register(sock, zmq.POLLIN)
      socks = dict(poller.poll(15000))
      assert(socks.get(sock) == zmq.POLLIN)
      resp = json.loads(sock.recv()[1:])
      assert('type' not in resp)
      assert(resp['body'] == 'test response\\n')
    EOS
                 )

    pid = fork do
      exec "#{bin}/zurl", "--config=#{conffile}"
    end

    begin
      system testpath/"vendor/bin/#{python3}", runfile
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end

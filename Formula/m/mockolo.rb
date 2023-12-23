class Mockolo < Formula
  desc "Efficient Mock Generator for Swift"
  homepage "https://github.com/uber/mockolo"
  url "https://github.com/uber/mockolo/archive/refs/tags/2.0.1.tar.gz"
  sha256 "78d940d0ed65876294923c26daaf0f912a65eea233b1902d90a0e4bc1c2c5e8d"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "751d8f2c81fbd38f76c4ce6d903af22f6e4538def9f9bf3eabc208e64ba85511"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f6f91ab3040d1314a29f89fee47d3c9a761bb2721f7c3380318060159e7ca5a7"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e35499379ecd08c9788eeaf08fba9173e3803bb294cc7b59cfa4701f2cfc0676"
    sha256 cellar: :any_skip_relocation, sonoma:         "26b77a01d5d1f07112cf7bb8fdfeff1b1d2dc7fc4f72cdfd06b608a71d58f812"
    sha256 cellar: :any_skip_relocation, ventura:        "30c17d788d6fe143cbb7e9d122a414b968b822cc2c9ae3bb84a12c755864f0bb"
    sha256 cellar: :any_skip_relocation, monterey:       "b676de9a5e6fe8733c2daeec89949388e145f6dc4650dca597ff4ab114066909"
    sha256                               x86_64_linux:   "6d87900eeee7ea0c0559e49ade2595e1aa0707c311e045581d8acace8ac558e6"
  end

  depends_on xcode: ["14.0", :build]

  uses_from_macos "swift"

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "mockolo"
    bin.install ".build/release/mockolo"
  end

  test do
    (testpath/"testfile.swift").write <<~EOS
      /// @mockable
      public protocol Foo {
          var num: Int { get set }
          func bar(arg: Float) -> String
      }
    EOS
    system "#{bin}/mockolo", "-srcs", testpath/"testfile.swift", "-d", testpath/"GeneratedMocks.swift"
    assert_predicate testpath/"GeneratedMocks.swift", :exist?
    output = <<~EOS.gsub(/\s+/, "").strip
      ///
      /// @Generated by Mockolo
      ///
      public class FooMock: Foo {
        public init() { }
        public init(num: Int = 0) {
            self.num = num
        }

        public private(set) var numSetCallCount = 0
        public var num: Int = 0 { didSet { numSetCallCount += 1 } }

        public private(set) var barCallCount = 0
        public var barHandler: ((Float) -> (String))?
        public func bar(arg: Float) -> String {
            barCallCount += 1
            if let barHandler = barHandler {
                return barHandler(arg)
            }
            return ""
        }
      }
    EOS
    assert_equal output, shell_output("cat #{testpath/"GeneratedMocks.swift"}").gsub(/\s+/, "").strip
  end
end
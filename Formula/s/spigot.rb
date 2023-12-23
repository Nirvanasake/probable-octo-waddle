class Spigot < Formula
  desc "Command-line streaming exact real calculator"
  homepage "https://www.chiark.greenend.org.uk/~sgtatham/spigot/"
  url "https://www.chiark.greenend.org.uk/~sgtatham/spigot/spigot-20220606.eb585f8.tar.gz"
  version "20220606"
  sha256 "27234d668fc750f5afe6b62d94d629f079740bb8b7cb11322a6fbbef2b0dec0a"
  license "MIT"

  livecheck do
    url :homepage
    regex(/href=.*?spigot[._-]v?(\d+(?:\.\d+)*)(?:[._-][\da-z]+)?\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "485e425d8512a17786bc423981b553a20233178390dcd0420ba4c97cf7bafba4"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "030a5c0fc3e0bee531208741bd5012b4fa2a5fe5e8fb2f079ffb6c37ac6babd1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2619cd7ae18bf5e034a5f061fbc8593b1ab5acfb890b5b4dbfe71a216b68e9c0"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "c7a514b7ac79c2c391a16ff6bb3534639ffa15306cefc586af1d5906c52c305c"
    sha256 cellar: :any_skip_relocation, sonoma:         "a95f6b1897e06a0d27b6fd78198d3744073e4498f6c6f478f1fb3aac80c81d36"
    sha256 cellar: :any_skip_relocation, ventura:        "97a406f8f490a381b27db40a24066629ade62f9ab34b8d9ad43fe2663a3590a9"
    sha256 cellar: :any_skip_relocation, monterey:       "9cd1259b84062a5e0fd8aec409cff82fa6df655667d34375c444e63730a5917d"
    sha256 cellar: :any_skip_relocation, big_sur:        "c3f1a1a5dd3c96d353c3db29ab681b4ea61823563386f9d143da6580edfdb050"
    sha256 cellar: :any_skip_relocation, catalina:       "8b1776395e9a1fc99a1910212e046381b307ea8f55726695b8c2d7c5a5cf0a36"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5741c9380e849ddefb17be31323a14c0e170d340a58f7c6c469e7637b0adf191"
  end

  depends_on "cmake" => :build

  uses_from_macos "ncurses"

  on_linux do
    depends_on "gmp"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    # Get Ramanujan's number of decimal places of Tau in base10
    expected = <<~EOS
      6.28318530717958647692528676655900576839433879875021164194988918461563281
      2572417997256069650684234135964296173026564613294187689219101164463450718
      8162569622349005682054038770422111192892458979098607639288576219513318668
      9225695129646757356633054240381829129713384692069722090865329642678721452
      0498282547449174013212631176349763041841925658508183430728735785180720022
      6610610976409330427682939038830232188661145407315191839061843722347638652
      2358621023709614892475992549913470377150544978245587636602389825966734672
      4881313286172042789892790449474381404359721887405541078434352586353504769
      3496369353388102640011362542905271216555715426855155792183472743574429368
      8180244990686029309917074210158455937851784708403991222425804392172806883
      6319627259549542619921037414422699999996745956099902119463465632192637190
      0489189106938166052850446165066893700705238623763420200062756775057731750
      6641676284123435533829460719650698085751093746231912572776470757518750391
      5563715561064342453613226003855753222391818432840397876190514402130971726
      5577318723067636559364606039040706037059379915472451988277824994435505669
      5826303114971448490830139190165906623372345571177815019676350927492987863
      8510120801855403342278019697648025716723207127415320209420363885911192397
      8935356748988965107595494536942080950692924160933685181389825866273540579
      7830420950432411393204811607630038702250676486007117528049499294652782839
      8545208539845593564709563272018683443282439849172630060572365949111413499
      6770109891771738539913818544215950186059106423306899744055119204729613309
      9823976366959550713273961485308505572510363683514934578195554558760016329
      4120032290498384346434429544700282883947137096322722314705104266951483698
      9368770466478147882866690955248337250379671389711241
    EOS
    assert_equal shell_output("#{bin}/spigot -d1729 tau").strip,
                 expected.delete!("\n")
  end
end
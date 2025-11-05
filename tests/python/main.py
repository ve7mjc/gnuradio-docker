# Checks for:
# - Python
# - GNU Radio python + core blocks
# - GNU Radio out-of-tree python blocks

gr_main_modules = ["gnuradio", "gnuradio.blocks", "gnuradio.fft"]
gr_oot_modules = ["satellites"]


def test_module(name: str):
    try:
        __import__(mod)
        print(f"✅ {mod}")
    except Exception as e:
        print(f"❌ {mod} - Failed to import: {e}")


if __name__ == "__main__":

    print("\nChecking Python module imports")

    # GNU Radio Primary blocks
    print("\nGNU Radio core and blocks")
    for mod in gr_main_modules:
        test_module(mod)

    print("\nGNU Radio out-of-tree modules")
    for mod in gr_oot_modules:
        test_module(mod)

    from test_gnuradio import test_gnuradio
    test_gnuradio()

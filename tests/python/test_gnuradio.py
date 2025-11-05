# import gnuradio
from gnuradio import gr
from gnuradio import analog, blocks

class TestFlowgraph(gr.top_block):
    def __init__(self):
        gr.top_block.__init__(self, "Test GNU Radio Installation")

        # Parameters
        sample_rate = 32000
        amplitude = 1.0

        # Blocks
        src = analog.sig_source_f(sample_rate, analog.GR_SIN_WAVE, 1000, amplitude)
        dst = blocks.null_sink(gr.sizeof_float)

        # Connections
        self.connect(src, dst)

def test_gnuradio():
    try:
        print("\nTesting GNU Radio installation...")
        tb = TestFlowgraph()
        tb.start()
        tb.stop()
        tb.wait()
        print("\nTest successful! GNU Radio is working!")
    except Exception as e:
        print(f"Test failed: {e}")

if __name__ == "__main__":
    test_gnuradio()

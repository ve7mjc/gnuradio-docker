for mod in ["gnuradio", "gnuradio.blocks", "gnuradio.fft", "satellites"]:
    try:
        __import__(mod)
        print(f"✅ {mod} imported successfully.")
    except Exception as e:
        print(f"❌ Failed to import {mod}: {e}")


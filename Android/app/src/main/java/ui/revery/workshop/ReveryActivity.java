package ui.revery.workshop;

import org.libsdl.app.SDLActivity;

public class ReveryActivity extends SDLActivity {

    static {
        System.loadLibrary("native-lib");
        startLogger("ui.revery.workshop");
    }

    @Override
    protected String[] getLibraries() {
        return new String[]{
                "main",
                "native-lib"
        };
    }

    public static native void startLogger(String tag);
}
#include <jni.h>
#include <string>
#include <unistd.h>
#include <pthread.h>
#include <android/log.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

extern "C" {
    extern void caml_startup_exn (char **argv);
}
//
extern "C" int SDL_main(int argc, char *argv[]) {
    // TODO: return a proper value
    caml_startup_exn(argv);
    return 0;
}

// stdout redirect
static int pfd[2];
static pthread_t thr;
static const char *app_tag;
static void *thread_func(void*)
{
    ssize_t rdsz;
    char buf[128];
    while((rdsz = read(pfd[0], buf, sizeof buf - 1)) > 0) {
        if(buf[rdsz - 1] == '\n') --rdsz;
        buf[rdsz] = 0;  /* add null-terminator */
        __android_log_write(ANDROID_LOG_DEBUG, app_tag, buf);
    }
    return 0;
}

extern "C"
JNIEXPORT void JNICALL
Java_ui_revery_workshop_ReveryActivity_startLogger(JNIEnv *env, jclass clazz, jstring jtag) {
    jboolean isCopy;
    const char* tag = (env)->GetStringUTFChars(jtag, &isCopy);
    app_tag = tag;

    /* make stdout line-buffered and stderr unbuffered */
    setvbuf(stdout, 0, _IOLBF, 0);
    setvbuf(stderr, 0, _IONBF, 0);

    /* create the pipe and redirect stdout and stderr */
    pipe(pfd);
    dup2(pfd[1], 1);
    dup2(pfd[1], 2);

    /* spawn the logging thread */
    if(pthread_create(&thr, 0, thread_func, 0) == -1)
        return;
    pthread_detach(thr);
}

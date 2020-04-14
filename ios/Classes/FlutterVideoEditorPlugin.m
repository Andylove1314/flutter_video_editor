#import "FlutterVideoEditorPlugin.h"
#if __has_include(<flutter_video_editor/flutter_video_editor-Swift.h>)
#import <flutter_video_editor/flutter_video_editor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_video_editor-Swift.h"
#endif

@implementation FlutterVideoEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVideoEditorPlugin registerWithRegistrar:registrar];
}
@end

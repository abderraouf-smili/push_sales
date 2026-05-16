import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

/// Field for picking image(s) from Gallery or Camera.
///
/// Field value is a list of objects.
///
/// the widget can internally handle displaying objects of type [XFile],[Uint8List],[String] (for an image url),[ImageProvider] (for any flutter image), [Widget] (for any widget)
/// and appends [XFile] to the list for picked images.
///
/// if you want to use a different object (e.g. a class from the backend that has imageId and imageUrl)
/// you need to implement [displayCustomType]
class MyImagePicker extends FormBuilderField<List<dynamic>> {
  //TODO: Add documentation
  final double previewWidth;
  final double previewHeight;
  final BoxShape boxShape;
  final EdgeInsets? previewMargin;
  final ImageProvider? placeholderImage;

  final Color? iconColor;

  /// Optional maximum height of image; see [ImagePicker].
  final double? maxHeight;

  /// Optional maximum width of image; see [ImagePicker].
  final double? maxWidth;

  /// The imageQuality argument modifies the quality of the image, ranging from
  /// 0-100 where 100 is the original/max quality. If imageQuality is null, the
  /// image with the original quality will be returned. See [ImagePicker].
  final int? imageQuality;

  /// Use preferredCameraDevice to specify the camera to use when the source is
  /// `ImageSource.camera`. The preferredCameraDevice is ignored when source is
  /// `ImageSource.gallery`. It is also ignored if the chosen camera is not
  /// supported on the device. Defaults to `CameraDevice.rear`. See [ImagePicker].
  final CameraDevice preferredCameraDevice;

  /// use this to get an image from a custom object to either [Uint8List] or [XFile] or [String] (url) or [ImageProvider]
  ///
  /// ```dart
  /// (obj) => obj is MyApiFileClass ? obj.imageUrl : obj;
  /// ```
  final dynamic Function(dynamic obj)? displayCustomType;

  final void Function(Image)? onImage;
  final int? maxImages;
  final Widget cameraIcon;
  final Widget galleryIcon;
  final Widget cameraLabel;
  final Widget galleryLabel;
  final EdgeInsets bottomSheetPadding;
  final bool preventPop;

  /// fit for each image
  final BoxFit fit;

  MyImagePicker({
    Key? key,
    //From Super
    required String name,
    FormFieldValidator<List<dynamic>>? validator,
    List<dynamic>? initialValue,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<List<dynamic>?>? onChanged,
    ValueTransformer<List<dynamic>?>? valueTransformer,
    bool enabled = true,
    FormFieldSetter<List<dynamic>>? onSaved,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    VoidCallback? onReset,
    FocusNode? focusNode,
    WidgetBuilder? loadingWidget,
    this.fit = BoxFit.cover,
    this.preventPop = false,
    this.displayCustomType,
    this.previewWidth = 130,
    this.previewHeight = 130,
    this.boxShape = BoxShape.rectangle,
    this.previewMargin,
    this.iconColor,
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    this.onImage,
    this.maxImages,
    this.cameraIcon = const Icon(Icons.camera_enhance),
    this.galleryIcon = const Icon(Icons.image),
    this.cameraLabel = const Text('Camera'),
    this.galleryLabel = const Text('Gallery'),
    this.bottomSheetPadding = EdgeInsets.zero,
    this.placeholderImage,
  })  : assert(maxImages == null || maxImages >= 0),
        super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          valueTransformer: valueTransformer,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          enabled: enabled,
          onReset: onReset,
          // decoration: decoration,
          focusNode: focusNode,
          builder: (FormFieldState<List<dynamic>?> field) {
            final state = field as _FormBuilderImagePickerState;
            final theme = Theme.of(state.context);
            final disabledColor = theme.disabledColor;
            final primaryColor = theme.primaryColor;
            final value = state.effectiveValue;
            final canUpload = state.enabled && !state.hasMaxImages;

            return InputDecorator(
              decoration: decoration,
              child: SizedBox(
                height: previewHeight,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: value.length + (canUpload ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < value.length) {
                      final item = value[index];
                      bool checkIfItemIsCustomType(dynamic e) => !(e is XFile ||
                          e is String ||
                          e is Uint8List ||
                          e is ImageProvider ||
                          e is Widget);

                      final itemCustomType = checkIfItemIsCustomType(item);
                      var displayItem = item;
                      if (itemCustomType && displayCustomType != null) {
                        displayItem = displayCustomType(item);
                      }
                      assert(
                        !checkIfItemIsCustomType(displayItem),
                        'Display item must be of type [Uint8List], [XFile], [String] (url), [ImageProvider] or [Widget]. '
                        'Consider using displayCustomType to handle the type: ${displayItem.runtimeType}',
                      );
                      return Stack(
                        key: ObjectKey(item),
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            width: previewWidth,
                            height: previewHeight,
                            margin: previewMargin,
                            child: displayItem is Widget
                                ? displayItem
                                : displayItem is ImageProvider
                                    ? Image(image: displayItem, fit: fit)
                                    : displayItem is Uint8List
                                        ? Image.memory(displayItem, fit: fit)
                                        : displayItem is String
                                            ? Image.network(
                                                displayItem,
                                                fit: fit,
                                              )
                                            : XFileImage(
                                                file: displayItem,
                                                fit: fit,
                                                loadingWidget: loadingWidget,
                                                boxShape: boxShape,
                                              ),
                          ),
                          if (state.enabled)
                            GestureDetector(
                              onTap: () {
                                // state.requestFocus();
                                field.didChange(
                                  value.toList()..removeAt(index),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.7),
                                  shape: BoxShape.circle,
                                ),
                                height: 40,
                                width: 40,
                                child: const Icon(
                                  Icons.close,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else {
                      return GestureDetector(
                        key: UniqueKey(),
                        child: Container(
                          width: previewWidth,
                          height: previewHeight,
                          decoration: BoxDecoration(
                            shape: boxShape,
                            color: (state.enabled
                                    ? iconColor ?? primaryColor
                                    : disabledColor)
                                .withAlpha(50),
                          ),
                          child: Icon(
                            Icons.camera_enhance,
                            color: state.enabled
                                ? iconColor ?? primaryColor
                                : disabledColor,
                            size: 50,
                          ),
                        ),
                        onTap: () async {
                          final remainingImages = maxImages == null
                              ? null
                              : maxImages - value.length;
                          await showModalBottomSheet<void>(
                            context: state.context,
                            builder: (_) {
                              return ImageSourceBottomSheet(
                                maxHeight: maxHeight,
                                maxWidth: maxWidth,
                                preventPop: preventPop,
                                remainingImages: remainingImages,
                                imageQuality: imageQuality,
                                preferredCameraDevice: preferredCameraDevice,
                                bottomSheetPadding: bottomSheetPadding,
                                cameraIcon: cameraIcon,
                                cameraLabel: cameraLabel,
                                galleryIcon: galleryIcon,
                                galleryLabel: galleryLabel,
                                onImageSelected: (image) {
                                  // state.requestFocus();
                                  field.didChange([...value, ...image]);
                                  // Navigator.pop(state.context);
                                },
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            );
          },
        );

  @override
  _FormBuilderImagePickerState createState() => _FormBuilderImagePickerState();
}

class _FormBuilderImagePickerState
    extends FormBuilderFieldState<MyImagePicker, List<dynamic>> {
  List<dynamic> get effectiveValue =>
      value?.where((element) => element != null).toList() ?? [];

  bool get hasMaxImages {
    final ev = effectiveValue;
    return widget.maxImages != null && ev.length >= widget.maxImages!;
  }
}

class XFileImage extends StatefulWidget {
  const XFileImage(
      {Key? key,
      required this.file,
      this.fit,
      this.loadingWidget,
      required this.boxShape})
      : super(key: key);
  final XFile file;
  final BoxFit? fit;
  final BoxShape boxShape;
  final WidgetBuilder? loadingWidget;

  @override
  State<XFileImage> createState() => _XFileImageState();
}

class _XFileImageState extends State<XFileImage> {
  final _memoizer = AsyncMemoizer<Uint8List>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _memoizer.runOnce(widget.file.readAsBytes),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return widget.loadingWidget?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }
        return Container(
          decoration: BoxDecoration(
              shape: widget.boxShape,
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      MemoryImage(data)) //Image.memory(data, fit: widget.fit)
              ),
        );
      },
    );
  }
}

class ImageSourceBottomSheet extends StatefulWidget {
  final double? maxHeight;
  final double? maxWidth;
  final int? imageQuality;
  final int? remainingImages;
  final CameraDevice preferredCameraDevice;

  final void Function(Iterable<XFile> files) onImageSelected;

  final Widget? cameraIcon;
  final Widget? galleryIcon;
  final Widget? cameraLabel;
  final Widget? galleryLabel;
  final EdgeInsets? bottomSheetPadding;
  final bool preventPop;

  const ImageSourceBottomSheet({
    Key? key,
    this.remainingImages,
    this.preventPop = false,
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    required this.onImageSelected,
    this.cameraIcon,
    this.galleryIcon,
    this.cameraLabel,
    this.galleryLabel,
    this.bottomSheetPadding,
  }) : super(key: key);

  @override
  _ImageSourceBottomSheetState createState() => _ImageSourceBottomSheetState();
}

class _ImageSourceBottomSheetState extends State<ImageSourceBottomSheet> {
  bool _isPickingImage = false;

  Future<void> _onPickImage(ImageSource source) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: widget.preferredCameraDevice,
        maxHeight: 680,
        maxWidth: 680,
        imageQuality: widget.imageQuality,
      );
      _isPickingImage = false;
      if (pickedFile != null) {
        widget.onImageSelected([pickedFile]);
      }
    } catch (e) {
      _isPickingImage = false;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _onPickImage(ImageSource.camera);
      Navigator.pop(context);
    });
    return SizedBox.shrink();
  }
}

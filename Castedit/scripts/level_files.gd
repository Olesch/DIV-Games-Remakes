class_name LevelFiles
extends Node
## Export / import of a level set as a LevelN.dat file (new, not in the original).
## Web: export is a browser download, import a hidden <input type=file> whose contents come back
## as bytes through JavaScriptBridge. Desktop: a native file dialog.

signal imported(file_name: String, bytes: PackedByteArray)
signal exported(message: String)

## Opens the browser's file picker; calls `callback(name, size)` once the chosen file is read and
## leaves its bytes in window.castleditImport.bytes for godot_js_eval to hand over.
const PICKER_JS := """
window.castleditImport = window.castleditImport || {
	bytes: null,
	pick: function (callback) {
		var input = document.createElement('input');
		input.type = 'file';
		input.accept = '.dat';
		input.style.display = 'none';
		input.addEventListener('change', function () {
			var file = input.files[0];
			input.remove();
			if (!file) return;
			file.arrayBuffer().then(function (buffer) {
				window.castleditImport.bytes = new Uint8Array(buffer);
				callback(file.name, buffer.byteLength);
			});
		});
		input.addEventListener('cancel', function () { input.remove(); });
		document.body.appendChild(input);
		input.click();
	}
};
"""

## Desktop: the OS file dialog (the autotest switches to Godot's own, which it can see and close).
var use_native_dialog := true
var _js_callback: JavaScriptObject   # must stay referenced while the picker is open
var _dialog: FileDialog
var _export_bytes := PackedByteArray()


func _ready() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(PICKER_JS, true)
		_js_callback = JavaScriptBridge.create_callback(_on_web_file_read)


func is_dialog_open() -> bool:
	return _dialog != null and _dialog.visible


## Returns a message for the toast.
func export_file(bytes: PackedByteArray, file_name: String) -> String:
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(bytes, file_name, "application/octet-stream")
		return "Exported %s (see your downloads)" % file_name
	_export_bytes = bytes
	_open_dialog(FileDialog.FILE_MODE_SAVE_FILE, file_name)
	return "Choose where to save %s" % file_name


func import_file() -> String:
	if OS.has_feature("web"):
		JavaScriptBridge.get_interface("castleditImport").pick(_js_callback)
		return "Choose a .dat file to import"
	_open_dialog(FileDialog.FILE_MODE_OPEN_FILE, "")
	return "Choose a .dat file to import"


func _on_web_file_read(args: Array) -> void:
	var bytes: Variant = JavaScriptBridge.eval("window.castleditImport.bytes", true)
	JavaScriptBridge.eval("window.castleditImport.bytes = null", true)
	imported.emit(str(args[0]), bytes if bytes is PackedByteArray else PackedByteArray())


func _open_dialog(mode: FileDialog.FileMode, file_name: String) -> void:
	if _dialog == null:
		_dialog = FileDialog.new()
		_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_dialog.filters = PackedStringArray(["*.dat ; DIV level set"])
		_dialog.file_selected.connect(_on_dialog_file_selected)
		add_child(_dialog)
	_dialog.use_native_dialog = use_native_dialog
	_dialog.file_mode = mode
	_dialog.title = "Export level set" if mode == FileDialog.FILE_MODE_SAVE_FILE else "Import level set"
	_dialog.current_file = file_name
	_dialog.popup_centered(Vector2i(700, 500))


func _on_dialog_file_selected(path: String) -> void:
	if _dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			exported.emit("Cannot write " + path)
			return
		f.store_buffer(_export_bytes)
		f.close()
		exported.emit("Exported to " + path)
	else:
		imported.emit(path.get_file(), FileAccess.get_file_as_bytes(path))

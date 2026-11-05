# fe Trainees (2026-11-05, run 2 task-02)

- `createSignedUrl` is async, so `TraineeRepository.photoUrl` returns `Future<String?>` (the
  package sketched a sync `String?`); `traineePhotoUrlProvider(path)` feeds `TraineeAvatar`.
- The package's interface had no way to clear a photo; `removePhoto(id)` was added
  (`set_trainee_photo` with null). Neither it nor a new upload deletes the old object, so
  replaced photos stay in the bucket as orphans until a cleanup exists.
- Storage errors are `StorageException` with an HTTP `statusCode`, not a SQLSTATE; the
  repository maps them itself because `mapSupabaseError` only knows Postgrest codes.
  An upload through the real Storage API is still untested (see `be-trainees-sessions.md`).
- image_picker 1.2.4 needs no AndroidManifest change: no CAMERA permission is declared, so
  the camera opens through an intent. Tests override `photoPickerProvider`.
- Widget tests: the form's `ListView` does not build the button or field errors off screen
  at 800x600; use a tall surface or `scrollUntilVisible`. "Add trainee" is both the form's
  AppBar title and its button text, so find the button by type.
- `find.bySemanticsLabel('Change photo')` needs semantics enabled; tapping the initials text
  opens the photo sheet as well.

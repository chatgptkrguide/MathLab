import { ref, uploadBytes, getDownloadURL, deleteObject } from "firebase/storage";
import { storage } from "./firebase";

export async function uploadProblemImage(file: File): Promise<string> {
  const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"];
  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new Error(`허용되지 않는 파일 형식: ${file.type}`);
  }
  const MAX_SIZE = 5 * 1024 * 1024;
  if (file.size > MAX_SIZE) {
    throw new Error("파일 크기는 5MB 이하여야 합니다.");
  }

  const timestamp = Date.now();
  const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
  const path = `problem_images/${timestamp}_${safeName}`;
  const storageRef = ref(storage, path);

  await uploadBytes(storageRef, file);
  const url = await getDownloadURL(storageRef);
  return url;
}

export async function deleteProblemImage(url: string): Promise<void> {
  try {
    // Extract storage path from download URL
    const decodedUrl = decodeURIComponent(url);
    const match = decodedUrl.match(/\/o\/(.+?)\?/);
    if (!match) {
      console.error("Failed to extract path from URL:", url);
      return;
    }
    const path = match[1];
    const storageRef = ref(storage, path);
    await deleteObject(storageRef);
  } catch (error) {
    console.error("Failed to delete image:", error);
  }
}

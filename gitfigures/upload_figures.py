import os
import fnmatch
import hashlib
import json
import pyoverleaf

base_dir = "gitfigures"
project_name = "ESD5_Semester_project"
checksum_cache_file = ".checksum_cache.json"

def find_image_files(directory):
    image_files = []
    for root, _, files in os.walk(directory):
        for pattern in ('*.png', '*.svg', '*.jpg'):
            for filename in fnmatch.filter(files, pattern):
                relative_path = os.path.relpath(os.path.join(root, filename), directory)
                image_files.append(relative_path)
    return image_files

def get_all_parent_directories(paths):
    dirs = set()
    for path in paths:
        parts = path.split(os.sep)
        for i in range(1, len(parts)):
            dir_path = os.sep.join(parts[:i])
            dirs.add(dir_path)
    return dirs

def get_remote_file_paths_and_dirs(folder, base_path=''):
    file_paths = []
    dir_paths = []
    if base_path != '':
        dir_paths.append(base_path)
    for child in folder.children:
        if child.type == "file":
            file_path = os.path.join(base_path, child.name)
            file_paths.append(file_path)
        elif child.type == "folder":
            subfolder_path = os.path.join(base_path, child.name)
            sub_file_paths, sub_dir_paths = get_remote_file_paths_and_dirs(child, subfolder_path)
            file_paths.extend(sub_file_paths)
            dir_paths.extend(sub_dir_paths)
    return file_paths, dir_paths

def compute_file_checksum(file_path):
    hash_sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        # Read and update hash in chunks of 4K
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()

def load_checksum_cache():
    if os.path.exists(checksum_cache_file):
        with open(checksum_cache_file, 'r') as f:
            return json.load(f)
    else:
        return {}

def save_checksum_cache(cache):
    with open(checksum_cache_file, 'w') as f:
        json.dump(cache, f, indent=4)

# Get local files and directories
directory = '.'
local_files = set(find_image_files(directory))
local_dirs = get_all_parent_directories(local_files)

# Compute local checksums
print("Computing local file checksums using SHA-256...")
local_checksums = {}
for f in local_files:
    local_checksums[f] = compute_file_checksum(f)

# Load checksum cache
checksum_cache = load_checksum_cache()

# Determine which files need to be uploaded based on checksum comparison
files_to_upload = set()
for f in local_files:
    local_checksum = local_checksums[f]
    cached_checksum = checksum_cache.get(f)
    if cached_checksum != local_checksum:
        files_to_upload.add(f)

# Connect to Overleaf
api = pyoverleaf.Api()
api.login_from_browser()
projects = api.get_projects()
project = next((p for p in projects if p.name == project_name), None)
if not project:
    raise Exception(f"Project '{project_name}' not found.")
project_id = project.id
root_folder = api.project_get_files(project_id)
io = pyoverleaf.ProjectIO(api, project_id)

# Get remote files and directories
remote_files_full, remote_dirs_full = get_remote_file_paths_and_dirs(root_folder)

# Filter and adjust paths under base_dir
remote_files_under_base = [f for f in remote_files_full if f.startswith(base_dir + '/')]
remote_dirs_under_base = [d for d in remote_dirs_full if d.startswith(base_dir + '/')]
remote_files_relative = [f[len(base_dir)+1:] for f in remote_files_under_base]
remote_dirs_relative = [d[len(base_dir)+1:] for d in remote_dirs_under_base]
remote_files_set = set(remote_files_relative)
remote_dirs_set = set(remote_dirs_relative)

# Compute differences
files_to_delete = remote_files_set - local_files
dirs_to_create = local_dirs - remote_dirs_set
dirs_to_delete = remote_dirs_set - local_dirs

# Delete remote files no longer present locally
if files_to_delete:
    print("Deleting remote files...")
    for f in files_to_delete:
        remote_path = os.path.join(base_dir, f)
        print(f"Deleting file: {remote_path}")
        try:
            io.remove(remote_path)
        except Exception as e:
            print(f"Error deleting file {remote_path}: {e}")
        # Remove from checksum cache
        if f in checksum_cache:
            del checksum_cache[f]

# Create directories on remote
if dirs_to_create:
    print("Creating directories...")
    for d in dirs_to_create:
        remote_path = os.path.join(base_dir, d)
        print(f"Creating directory: {remote_path}")
        io.mkdir(remote_path, parents=True, exist_ok=True)

# Upload files that need to be updated
if files_to_upload:
    print("Uploading files...")
    for f in files_to_upload:
        remote_path = os.path.join(base_dir, f)
        print(f"Uploading file: {remote_path}")
        with io.open(remote_path, "wb+") as remote_file:
            with open(f, "rb") as local_file:
                data = local_file.read()
                remote_file.write(data)
        # Update checksum cache
        checksum_cache[f] = local_checksums[f]
else:
    print("No files need to be uploaded.")

# Delete remote directories no longer present locally
if dirs_to_delete:
    dirs_to_delete_sorted = sorted(dirs_to_delete, key=lambda x: x.count(os.sep), reverse=True)
    print("Deleting remote directories...")
    for d in dirs_to_delete_sorted:
        remote_path = os.path.join(base_dir, d)
        print(f"Deleting directory: {remote_path}")
        try:
            io.remove(remote_path)
        except Exception as e:
            print(f"Error deleting directory {remote_path}: {e}")

# Save updated checksum cache
save_checksum_cache(checksum_cache)

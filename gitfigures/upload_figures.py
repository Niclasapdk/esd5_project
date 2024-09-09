# To run follow the installation instructions for pyoverleaf
# make sure you're logged into overleaf on firefox or chrome
# and that it is your default browser
# https://github.com/jkulhanek/pyoverleaf
import os
import fnmatch

base_dir = "gitfigures"
project_name = "ESD5_Semester_project"

def find_png_images(directory):
    png_files = []
    for root, _, files in os.walk(directory):
        for filename in fnmatch.filter(files, '*.png'):
            png_files.append(os.path.join(root, filename))
        for filename in fnmatch.filter(files, '*.svg'):
            png_files.append(os.path.join(root, filename))
        for filename in fnmatch.filter(files, '*.jpg'):
            png_files.append(os.path.join(root, filename))
    png_files = [name.replace("./", "") for name in png_files]
    return png_files

def get_deepest_subdirectories(filenames):
    deepest_subdirectories = set()
    for file in filenames:
        # Get the directory part of the file path
        dir_path = os.path.dirname(file)
        if len(dir_path) == 0:
            continue
        # Check if the directory has subdirectories
        while os.path.isdir(dir_path):
            subdirs = [os.path.join(dir_path, sub) for sub in os.listdir(dir_path) if os.path.isdir(os.path.join(dir_path, sub))]
            if subdirs:
                dir_path = max(subdirs, key=lambda s: s.count(os.sep))  # Find the deepest subdirectory
            else:
                break
        deepest_subdirectories.add(dir_path)
    return list(deepest_subdirectories)

directory = '.'
png_images = find_png_images(directory)

import pyoverleaf
api = pyoverleaf.Api()
api.login_from_browser()
projects = api.get_projects()
project = list(filter(lambda p: p.name == project_name, projects))[0]
project_id = project.id
root_folder = api.project_get_files(project_id)
io = pyoverleaf.ProjectIO(api, project_id)

print("Making subdirectories")
for subdir in get_deepest_subdirectories(png_images):
    dirname = os.path.join(base_dir, subdir)
    print(dirname)
    io.mkdir(dirname, parents=True, exist_ok=True)

# make subdirectories
io = pyoverleaf.ProjectIO(api, project_id)
print("Uploading images")
for img in png_images:
    imgname = os.path.join(base_dir, img)
    print(imgname)
    with io.open(imgname, "wb+") as f:
        with open(img, "rb") as i:
            f.write(i.read())

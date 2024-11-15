import os
from datetime import datetime

# Global version variable
VERSION = None

def stb_outfile_name(filename, dir="./out"):
    global VERSION
    
    # Set VERSION if it is not already set
    if VERSION is None:
        VERSION = datetime.now().strftime("%Y%m%d")
    
    # Remove trailing slash from directory if present
    dir = dir.rstrip(os.sep)
    
    # Return the file path
    return os.path.join(dir, f"{VERSION}-{filename}")


from dotenv import load_dotenv
from requests import get
from os import getenv
from sys import exit, stderr

NO_CHANGE = 0
CHANGE = 1
def get_sha() -> str:
    resp = get(
        f"{GITHUB_API_URL}/{OWNER}/{REPO}/commits/{REF}",
        headers=HEADER
    )
    if resp.status_code != 200:
        return 'empty'
    return resp._content.decode('utf-8')

def check_sha(sha: str) -> bool:
    f = open('./last_sha.txt', 'r+')
    if sha != f.read():
        print("Changed, need to pull last change.")
        f.seek(0)
        f.write(sha)
        f.truncate()
        f.close()
        return True
    else:
        print("Nothing Change.")
        f.close()
        return False

if __name__ == '__main__':
    load_dotenv()

    GITHUB_ACCESS_TOKEN = getenv('GITHUB_ACCESS_TOKEN')
    OWNER = getenv('OWNER')
    REPO = getenv('REPO')
    REF = getenv('REF')
    GITHUB_API_URL = 'https://api.github.com/repos'
    HEADER = {
        "Accept": "application/vnd.github.sha",
        "Authorization": f"Bearer {GITHUB_ACCESS_TOKEN}",
        "X-GitHub-Api-Version": "2022-11-28"
    }

    sha: str = get_sha()
    if sha == 'empty':
        print("Repo is empty.", file=stderr)
        exit(NO_CHANGE)
    print(f"get new sha: {sha}")
    exit(CHANGE) if check_sha(sha) == True else exit(NO_CHANGE)

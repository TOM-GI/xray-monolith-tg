#include "stdafx.h"
#include "ShaderFileWatcher.h"
#include "ResourceManager.h"

CShaderFileWatcher::CShaderFileWatcher()
	: m_bTerminate(FALSE)
	, m_hThread(NULL)
	, m_pResManager(NULL)
{
	m_watchDir[0] = 0;
}

CShaderFileWatcher::~CShaderFileWatcher()
{
	Stop();
}

void CShaderFileWatcher::Start(CResourceManager* pResManager)
{
	if (m_hThread)
		return; // already running

	m_pResManager = pResManager;

	// Resolve shader directory path
	FS.update_path(m_watchDir, "$game_shaders$", ::Render->getShaderPath());

	// Verify directory exists
	DWORD attrib = GetFileAttributesA(m_watchDir);
	if (attrib == INVALID_FILE_ATTRIBUTES || !(attrib & FILE_ATTRIBUTE_DIRECTORY))
	{
		Msg("! shader_watch: directory '%s' not found", m_watchDir);
		return;
	}

	m_bTerminate = FALSE;
	m_hThread = CreateThread(NULL, 0, WatchThread, this, 0, NULL);

	if (m_hThread)
		Msg("* shader_watch: watching '%s'", m_watchDir);
	else
		Msg("! shader_watch: failed to create watcher thread");
}

void CShaderFileWatcher::Stop()
{
	if (!m_hThread)
		return;

	m_bTerminate = TRUE;

	// Wait for thread to finish (with timeout)
	WaitForSingleObject(m_hThread, 3000);
	CloseHandle(m_hThread);
	m_hThread = NULL;

	Msg("* shader_watch: stopped");
}

DWORD WINAPI CShaderFileWatcher::WatchThread(LPVOID param)
{
	CShaderFileWatcher* self = (CShaderFileWatcher*)param;

	HANDLE hDir = CreateFileA(
		self->m_watchDir,
		FILE_LIST_DIRECTORY,
		FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
		NULL,
		OPEN_EXISTING,
		FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED,
		NULL
	);

	if (hDir == INVALID_HANDLE_VALUE)
	{
		Msg("! shader_watch: failed to open directory for watching");
		return 1;
	}

	OVERLAPPED overlapped = {};
	overlapped.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

	char buffer[4096];

	while (!self->m_bTerminate)
	{
		DWORD bytesReturned = 0;
		ResetEvent(overlapped.hEvent);

		BOOL result = ReadDirectoryChangesW(
			hDir,
			buffer,
			sizeof(buffer),
			FALSE,  // don't watch subtrees
			FILE_NOTIFY_CHANGE_LAST_WRITE,
			&bytesReturned,
			&overlapped,
			NULL
		);

		if (!result)
			break;

		// Wait with timeout so we can check m_bTerminate
		DWORD waitResult = WaitForSingleObject(overlapped.hEvent, 500);

		if (self->m_bTerminate)
			break;

		if (waitResult != WAIT_OBJECT_0)
			continue; // timeout, loop again

		if (!GetOverlappedResult(hDir, &overlapped, &bytesReturned, FALSE))
			continue;

		// Process notifications
		FILE_NOTIFY_INFORMATION* pNotify = (FILE_NOTIFY_INFORMATION*)buffer;

		while (pNotify)
		{
			// Convert wide filename to narrow
			char filename[MAX_PATH];
			int len = WideCharToMultiByte(CP_ACP, 0,
				pNotify->FileName, pNotify->FileNameLength / sizeof(WCHAR),
				filename, MAX_PATH - 1, NULL, NULL);
			filename[len] = 0;

			self->ProcessChange(filename);

			if (pNotify->NextEntryOffset == 0)
				break;
			pNotify = (FILE_NOTIFY_INFORMATION*)((char*)pNotify + pNotify->NextEntryOffset);
		}
	}

	CloseHandle(overlapped.hEvent);
	CloseHandle(hDir);
	return 0;
}

void CShaderFileWatcher::ProcessChange(const char* filename)
{
	if (!m_pResManager)
		return;

	// Extract name and extension
	size_t len = xr_strlen(filename);

	// Check for .ps or .vs extension
	bool isPS = (len > 3 && 0 == stricmp(filename + len - 3, ".ps"));
	bool isVS = (len > 3 && 0 == stricmp(filename + len - 3, ".vs"));

	if (!isPS && !isVS)
		return;

	// Strip extension to get shader name
	string_path shaderName;
	xr_strcpy(shaderName, filename);
	shaderName[len - 3] = 0;

	// Small delay to let the file finish writing
	Sleep(50);

	if (isPS)
	{
		Msg("* shader_watch: detected change in '%s', reloading PS...", filename);
		m_pResManager->ReloadPS(shaderName);
	}
	else if (isVS)
	{
		Msg("* shader_watch: detected change in '%s', reloading VS...", filename);
		m_pResManager->ReloadVS(shaderName);
	}
}

#ifndef ShaderFileWatcherH
#define ShaderFileWatcherH
#pragma once

class CResourceManager;

class CShaderFileWatcher
{
private:
	volatile BOOL m_bTerminate;
	HANDLE m_hThread;
	CResourceManager* m_pResManager;
	string_path m_watchDir;

	static DWORD WINAPI WatchThread(LPVOID param);
	void ProcessChange(const char* filename);

public:
	CShaderFileWatcher();
	~CShaderFileWatcher();

	void Start(CResourceManager* pResManager);
	void Stop();
};

#endif

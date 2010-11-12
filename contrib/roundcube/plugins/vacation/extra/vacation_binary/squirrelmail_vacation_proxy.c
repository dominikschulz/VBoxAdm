/*
 * squirrelmail_vacation_proxy.c
 *
 * Accesses local files in a user's home directory
 *
 * Instalation:	   
 *	Should be owned by root and suid root.
 *	If RESTRICTUSE was enabled at compile time then the executing user
 *	(real user) must have the same uid as the user defined by WEBUSER
 *	If NOROOT was enabled at compile time then this program may not be
 *      executed on behalf of the root user
 * 
 * Actions:
 *		list get put delete 
 *
 * Syntax:	squirrelmail_vacation_proxy  server user password action source destination
 */
 
#define BUFSIZE 512
#define MAXEMAILADRESSES 40
#define FIELDS	5

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <syslog.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <pwd.h>
#include <string.h>

#include <errno.h>

#include <crypt.h>

#ifdef USESHADOW
#include <shadow.h>
#endif /* USESHADOW */

#define	SERVER	1
#define	USER	2
#define	PSWD	3
#define	ACTION	4
#define	SRC	5
#define	DEST	6

char	*actions[] = {
	"list",
	"get",
	"put",
	"delete",
	0
}; 


 int my_system (const char *command, char **envp) {
           int pid, status;
 
           if (command == 0)
               return 1;
           pid = fork();
           if (pid == -1)
               return -1;
           if (pid == 0) {
               char *argv[4];
               argv[0] = "sh";
               argv[1] = "-c";
               argv[2] = command;
               argv[3] = 0;
               execve("/bin/sh", argv, envp);
               exit(127);
           }
           do {
               if (waitpid(pid, &status, 0) == -1) {
                   if (errno != EINTR)
                       return -1;
               } else
                   return status;
           } while(1);
       }




main (argc, argv, envp)
int argc;
char *argv[];
char *envp[];
{
	 char line[BUFSIZE];
	 char *puid, *testpwd; 
	 char *pemail[FIELDS];
	 unsigned int noemail = 0;
	 struct passwd *pw, *getpwnam();
#ifdef USESHADOW
	 struct spwd *spw, *getspnam();
#endif /* USESHADOW */
	 struct passwd *pwebuser;
	 FILE *fd, *f;
	char	**ptr;
	int	notFound;
	struct stat statbuf;
	char	curdir[BUFSIZE];

	 int i; // To be used in for-loops
#ifdef RESTRICTUSE
	 /* RESTRICTUSE is defined.
	Then we start with a check to see if the real user is
	the valid user. */
	if ((pwebuser=getpwnam(WEBUSER))==NULL)
	{
		printf("Invalid webuser. %s\n");
		exit(1);
	}
	if( pwebuser->pw_uid != getuid() )
	{
		printf("Invalid real user.\n");
		exit(1);
	}
#endif /* RESTRICTUSE */

	if (argc != 7) {
		printf("Usage: %s server user password [list|put|get|delete] source destination \n",argv[0]);
		exit(1);
	}

	if (strstr(argv[SRC], ";") != NULL || strstr(argv[DEST], ";") != NULL
	 || strstr(argv[SRC], "|") != NULL || strstr(argv[DEST], "|") != NULL
	 || strstr(argv[SRC], "`") != NULL || strstr(argv[DEST], "`") != NULL
	 || strstr(argv[SRC], "&") != NULL || strstr(argv[DEST], "&") != NULL
	 || strstr(argv[SRC], "\n") != NULL || strstr(argv[DEST], "\n") != NULL
	 || strstr(argv[SRC], "\r") != NULL || strstr(argv[DEST], "\r") != NULL
	 || strstr(argv[SRC], "(") != NULL || strstr(argv[DEST], "(") != NULL
	 || strstr(argv[SRC], ")") != NULL || strstr(argv[DEST], ")") != NULL
	 || strstr(argv[SRC], "[") != NULL || strstr(argv[DEST], "[") != NULL
	 || strstr(argv[SRC], "]") != NULL || strstr(argv[DEST], "]") != NULL
	 || strstr(argv[SRC], "*") != NULL || strstr(argv[DEST], "*") != NULL
	/* || strstr(argv[SRC], "?") != NULL || strstr(argv[DEST], "?") != NULL */
	 || strstr(argv[SRC], "{") != NULL || strstr(argv[DEST], "{") != NULL
	 || strstr(argv[SRC], "}") != NULL || strstr(argv[DEST], "}") != NULL
	 || strstr(argv[SRC], "~") != NULL || strstr(argv[DEST], "~") != NULL
	 || strstr(argv[SRC], "$") != NULL || strstr(argv[DEST], "$") != NULL
	 || strstr(argv[SRC], "^") != NULL || strstr(argv[DEST], "^") != NULL
	/* || strstr(argv[SRC], "\\") != NULL || strstr(argv[DEST], "\\") != NULL */
	 || strstr(argv[SRC], "'") != NULL || strstr(argv[DEST], "'") != NULL
	 || strstr(argv[SRC], "\"") != NULL || strstr(argv[DEST], "\"") != NULL
	 || strstr(argv[SRC], "!") != NULL || strstr(argv[DEST], "!") != NULL)
	{
		printf("Suspicious metacharacters not allowed\n ");
		exit(1);
	}


	if (strstr(argv[SRC], "..") != NULL || strstr(argv[DEST], "..") != NULL)
	{
#ifdef DEBUG
		printf("Directory traversal not allowed: %s or %s\n ", argv[SRC], argv[DEST]);
#else
		printf("Directory traversal not allowed\n ");
#endif /* DEBUG */
		exit(1);
	}


#ifdef NOROOT
	if (strcmp(argv[USER], "root") == 0)
	{
		printf("root not allowed\n ");
		exit(1);
	}
#endif /* NOROOT */

	puid = argv[USER];

	if ((pw=getpwnam(puid))==NULL)
	{
		printf("Invalid user\n ");
		exit(1);
	}

#ifdef USESHADOW
	if ((spw=getspnam(puid))==NULL)
	{
		printf("Invalid user\n ");
		exit(1);
	}
	testpwd = crypt(argv[PSWD], spw->sp_pwdp);
	if (strcmp(testpwd, spw->sp_pwdp) != 0)
	{
		printf("Bad password\n ");
		exit(1);
	}
#else
	testpwd = crypt(argv[PSWD], pw->pw_passwd);
	if (strcmp(testpwd, pw->pw_passwd) != 0)
	{
		printf("Bad password\n ");
		exit(1);
	}
#endif /* USESHADOW */

	setuid(0);
#if 0
	if (setgid (pw->pw_gid) == -1)
	{
		printf("setgid errno: %d\n", errno);
	}
	if (setuid (pw->pw_uid) == -1)
	{
		printf("setuid errno: %d\n", errno);
	}
#endif
	getcwd(curdir, sizeof(curdir));
	
	notFound = 1;
	for (ptr = actions; *ptr; ptr++)
	{
		if (strcmp(*ptr, argv[ACTION]) == 0)
		{
			notFound = 0;
		}
	}
	if (notFound)
	{
		printf("Action not found\n");
		exit(1);
	}
	// Since each command begins with a different letter, we can switch
	// based on the first letter.

	switch (argv[ACTION][0])
	{
		case 'l':	// list
			{
				if( snprintf(line, BUFSIZE, "%s/%s", pw->pw_dir, argv[SRC]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}
				if (stat(line, &statbuf) == 0)
				{
					printf("%s", argv[SRC]);
				}
				else
				{
					printf("");
				}
			}
			break;

		case 'g':	// get
				if( snprintf(line, BUFSIZE, "%s/%s", pw->pw_dir, argv[SRC]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}
				if (stat(line, &statbuf) )
				{
					printf("File doesn't exist<BR>");
					exit(1);
				}
				if (argv[DEST][0] == '/')
					curdir[0] = 0;
				if( snprintf(line, BUFSIZE, "/bin/cp %s/%s %s/%s; chmod 444 %s/%s", pw->pw_dir, argv[SRC], curdir, argv[DEST], curdir, argv[DEST]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}

				i = my_system(line, envp);
				if (stat(argv[DEST], &statbuf) )
				{
					exit(1);
				}
				printf("%s", argv[DEST]);
				break;

		case 'p':	// put
				if (argv[SRC][0] == '/')
					curdir[0] = 0;
				if( snprintf(line, BUFSIZE, "%s/%s", curdir, argv[SRC]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}
				if (stat(line, &statbuf) )
				{
					printf("File doesn't exist<BR>");
					exit(1);
				}
				if( snprintf(line, BUFSIZE, "/bin/cp %s/%s %s/%s", curdir, argv[SRC], pw->pw_dir, argv[DEST]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}

				i = my_system(line, envp);
				if( snprintf(line, BUFSIZE, "%s/%s", pw->pw_dir, argv[DEST]) > BUFSIZE ) 
				{
					exit(1);
				}

				chown(line, pw->pw_uid, pw->pw_gid);

				printf("%s", argv[DEST]);
				break;
		case 'd':	// delete
				if( snprintf(line, BUFSIZE, "%s/%s", pw->pw_dir, argv[SRC]) > BUFSIZE ) 
				{
					printf("Supplied users homedir path too long.\n");
					exit(1);
				}
				if (stat(line, &statbuf) == 0)
				{
					unlink(line);
					printf("%s", line);
				}
				else
				{
				}
			break;
	}
	
	exit(0);
}

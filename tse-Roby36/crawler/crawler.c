
#include "crawler.h"

int main(const int argc, char* argv[]) {

    char* seedURL;
    char* pageDirectory;
    int* maxDepthp = malloc(sizeof(int));

    parseArgs(argc, argv, &seedURL, &pageDirectory, maxDepthp);

    crawl(seedURL, pageDirectory, *maxDepthp);

    free(pageDirectory);
    free(maxDepthp);

	return 0;
}

static void parseArgs(const int argc, char* argv[], char** seedURL, char** pageDirectory, int* maxDepth){

    const char* progName = argv[0];

    if (argc != 4) {
		fprintf(stderr, "Usage: %s seedURL pageDirectory maxDepth\n", progName);
		exit(1);
    }

    char* normalizedURL = normalizeURL(argv[1]);
    
    if (normalizedURL == NULL) {
        fprintf(stderr, "%s: URL could not be normalized; please enter valid URL\n", progName);
        exit(2);
    }

#ifdef INTERNAL_CHECK
    if (!isInternalURL(normalizedURL)) {
        fprintf(stderr, "%s: External URL\n", progName);
        exit(3);
    }
#endif //INTERNAL_CHECK

	/* Copy normalized url (already malloc'd) */
    *seedURL = normalizedURL;

    if (!pagedir_init(argv[2], "/.crawler")) {
        fprintf(stderr, "%s: Failed to create .crawler file: please enter valid directory.\n", progName);
        exit(5);
    }

	/* Allocate space for the page directory */
    *pageDirectory = malloc(strlen(argv[2]) + 1);
    strncpy(*pageDirectory, argv[2], strlen(argv[2]) + 1);

    if (!str2int(argv[3], maxDepth)) {                                                                 
      fprintf(stderr,"%s: maxDepth must be an integer.\n", progName); 
      exit(8);                                                     
    } else if ( *maxDepth < 0 || *maxDepth > 10){
      fprintf(stderr,"%s: maxDepth must be between [0,10]\n", progName); 
      exit(9);                                                    
    }
}

static void crawl(char* seedURL, char* pageDirectory, const int maxDepth){

	int currDocID = 1;

	hashtable_t* pagesSeen = hashtable_new(HASHTABLE_SIZE);
	if (pagesSeen == NULL) {
		fprintf(stderr, "Error creating hashtable for visited pages.\n");
		return;
	}

	linked_list_t* pagesToCrawl = linked_list_new();
	if (pagesToCrawl == NULL) {
		fprintf(stderr, "Error creating linekd list for pages to visit.\n");
		return;
	}

	webpage_t* currPage = webpage_new(seedURL, 0, NULL);
	if (currPage == NULL) {
		fprintf(stderr, "Error creating webpage for seed URL.\n");
		return;
	}
	
	if (!hashtable_insert(pagesSeen, seedURL, "URL")) {
		fprintf(stderr, "Error adding webpage to hashtable for seed URL.\n");
		return;
	}

	linked_list_insert2(pagesToCrawl, currPage, 0);
	logr("Added", webpage_getDepth(currPage), webpage_getURL(currPage));

	while ((currPage = linked_list_extract2(pagesToCrawl, 0)) != NULL) {

		if (!webpage_fetch(currPage)) {
			fprintf(stderr, "Error fetching webpage %s.\n", webpage_getURL(currPage));
			continue;
		}
		
		logr("Fetched", webpage_getDepth(currPage), webpage_getURL(currPage));
		pagedir_save(currPage, pageDirectory, currDocID);
		currDocID++;

		if (webpage_getDepth(currPage) < maxDepth)	{
			pageScan(currPage, pagesToCrawl, pagesSeen);
		}
		webpage_delete((void*)currPage);
	}
	linked_list_delete(pagesToCrawl, webpage_delete);
	hashtable_delete(pagesSeen, nodelete);
}

static void pageScan(webpage_t* page, linked_list_t* pagesToCrawl, hashtable_t* pagesSeen) {

	int pos = 0;
	char* currURL;
	
	while ( (currURL = webpage_getNextURL(page, &pos)) != NULL ) {
#ifdef INTERNAL_CHECK
		if (!isInternalURL(currURL)) {
			logr("External", webpage_getDepth(page), currURL);
			free(currURL);
			continue;
		}
#endif
		if (!hashtable_insert(pagesSeen, currURL, "URL")) 
			continue;

		char* copyURL = malloc(strlen(currURL) + 1);
		strncpy(copyURL, currURL, strlen(currURL) + 1);

		webpage_t* newPage = webpage_new(copyURL, webpage_getDepth(page) + 1, NULL);
		if (newPage == NULL) {
			fprintf(stderr, "Error creating webpage for %s\n",copyURL);
			continue;
		}
		linked_list_insert2(pagesToCrawl, newPage, 0);
		logr("Added", webpage_getDepth(newPage), webpage_getURL(newPage));
	}
}

static bool str2int(const char string[], int *number) { 

	char nextchar;
  	if (sscanf(string, "%d%c", number, &nextchar) == 1)  
    	return true; 
	return false;
}

static void logr(const char *word, const int depth, const char *url)
{
#ifdef LOGGING
  printf("%2d %*s%9s: %s\n", depth, depth, "", word, url);
#endif
}

static void nodelete(void* item)
{
}

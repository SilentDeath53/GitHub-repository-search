import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/log;

string baseUrl = "https://api.github.com/";

function searchRepositories(string query, int perPage, int page) returns json | error {
    string url = baseUrl + "search/repositories?q=" + http:uriEncode(query) + "&per_page=" + perPage.toString() + "&page=" + page.toString();
    http:Request req = new;
    req.setUri(url);
    req.setHeader("User-Agent", "Ballerina GitHub Search");
    
    http:Response response = check http:send(req);
    if (response is http:Response) {
        match response.getJsonPayload() {
            json payload => return payload;
            error err => return err;
        }
    } else {
        return response;
    }
}

public function main() {
    string searchQuery = config:getAsString("SEARCH_QUERY", defaultValue = "ballerina");
    int pageSize = config:getAsInt("PAGE_SIZE", defaultValue = 10);
    int pageNumber = config:getAsInt("PAGE_NUMBER", defaultValue = 1);

    json|error result = searchRepositories(searchQuery, pageSize, pageNumber);
    if (result is json) {
        json repositories = result;
        io:println("Found " + repositories.total_count.toString() + " repositories for query '" + searchQuery + "':");
        foreach repo in repositories.items {
            io:println(repo.name + " - " + repo.description);
        }
    } else {
        log:printError("Error occurred while searching repositories: ", result);
    }
}

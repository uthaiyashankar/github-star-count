import ballerina/http;
import ballerinax/github;

configurable string authToken = ?;

type RepoStar record{
    string name;
    int star;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + orgName - name of the github organization
    # + numberOfRepos - number of repos to be returned
    # + return - string name with hello message or error
    resource function get most\-star\-repos(string orgName, int numberOfRepos) returns RepoStar[]|error {
        
        github:ConnectionConfig config = {
        auth: {
                token: authToken
            }
        };

        github:Client githubClient = check new (config);
        var repositories = check githubClient->getRepositories(orgName, true);
        //Get the names. 
        RepoStar[]? names = check from var repository in repositories
        order by repository.stargazerCount descending
        limit numberOfRepos
        select {
            name: repository.name, 
            star: repository.stargazerCount?:0};

        if names is () {
            return error ("Unknown error");
        }

        return names;
    }
}

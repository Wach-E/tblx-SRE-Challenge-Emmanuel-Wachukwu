# SRE Challenge - Task 1

### Objective
Build an application with an API endpoint that receives a path from Wikipedia, [fetches](https://en.wikipedia.org/wiki/Special:ApiSandbox#action=parse&format=json&page=Word_list&prop=wikitext) its content and returns its [word list](https://en.wikipedia.org/wiki/Word_list). 

The app:
- may use any technology stack but must run on Linux
- must be containerized

### Solution Decisions
**Wikimedia/Wikipedia**: Wikimedia has 6 major apis used for data content collection as described [here](https://www.mediawiki.org/wiki/API:Main_page). The Wikipedia Mediawiki API would have been great for this task except for the fact that it returns data is in an unstrutured form when using either `parse` or `query` **actions** and the data type of `xml` and `json` limits the data collected as it lacks identifiers for direct data collection. Considering the scope of this application would need to consume only **one** Wikipedia webpage, **Daimler Truck**, I thought it be a better approach to directly request the webpage url and transform it into the wordlist.

**Programming Language**: From my previous experience with the Wikimedia Foundation, **Python** works best for most of her projects. Although, the final solution of this application has no direct dependence on Wikimedia but, at the early stage of developing this application where I used the MediaWiki API, python seemed to integrate best with most of Wikidata projects and hence, my choice of programming language.

**Framework**: To keep this appliction simple, I built the api endpoint using Flask. [Flask](https://flask.palletsprojects.com/en/2.1.x/) is a lightweight python framework used for the development of web applications.

**Container Technology**: Docker was used as the container technology for this task.

**Testing**: Pytest was used for running unit tests of the application api.

**Monitoring**: Application logging was used as a monitoring solution for this task. The Python logging module was used to write logs to a specific file. This decision was made with the consideration of the indirect approach to application logging (logging agent -> backend server -> visualization tool). 
The application logs could be retrieved by a **logging agent** such as Filebeat (by Elastic), Promtail (by Grafana) fluentd, Fluent Bit etc., transferred  to **storage backends** such as Elasticsearch (by Elastic), Logstash (by Elastic; processing only, no storage), Loki (by Grafana) and visualized in a **UI** such as Kibana (the UI for Elasticsearch), Grafana (supports different backends) etc.

**Application development workflow**: The workflow for the development of this application are as follows:
- Setup of development environment.
- Setup of virtual environment.
- Application development

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 1 - Documentation](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/develop/Task%201%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-1) was created from the **development** branch.

## Extra points implemented
- Application logging
- Unit test


# Generals

The definition of the problem is [here](https://gist.github.com/einzige/0012fa419d4dac1456a769f82e9588b4)

The seeding data is [here](https://gist.github.com/einzige/69a5af5a9df1a483c2745f604e4fe1ba)

This app utilizes [Framework](https://github.com/einzige/framework) v0.0.9 and rocks MIT license.

# Usage

## 1. Seed the data
```
Seed.instance.teams(teams_file: 'folder/to/teams.csv', performance_file: 'folder/to/performance.csv')
Seed.instance.tasks(file: 'folder/to/tasks.csv')
```

## 2. Assign tasks
```
Manager.instance.assing_all_tasks!
```

## 3. Generate the report
```
Report.new(file_name: 'folder/to/report.csv').generate!
```

## 4. Open the report :)

# Heads up

There is an error in the data output. Here is the good one:
```
SCHEDULE
----------------------------------------
TEAM    | Local time | UTC time | TASK №
----------------------------------------
Moscow  | 9am-1pm    | 6am-10am | 1
London  | 9am-2pm    | 9am-2pm  | 2
Moscow  | 1pm-7pm    | 10am-4pm | 4
London  | 2pm-6pm    | 2pm-6pm  | 3
```
Here is the wrong one (there is a problem with the UTC time of London):
```
SCHEDULE
----------------------------------------
TEAM    | Local time | UTC time | TASK №
----------------------------------------
Moscow  | 9am-1pm    | 6am-10am | 1
London  | 9am-2pm    | 8am-1pm  | 2
Moscow  | 1pm-7pm    | 10am-4pm | 4
London  | 2pm-6pm    | 1pm-5pm  | 3
```

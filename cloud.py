# import os
# from pathlib import Path

# project_directory = Path(__file__).parent
# data_file_names = os.listdir(os.path.join(project_directory, "data"))


# print(data_file_names)


# def create_delegation(data_file_names):
#     delegation = []
#     files_per_app = [] 
#     for filename in data_file_names:
#         files_per_app.append(filename)

#         if len(files_per_app) >= 10:
#             delegation.append({"files":files_per_app.copy(), "hostname":f"worker-target-{len(delegation)}"})
#             files_per_app = []
#     if len(files_per_app) > 0:
#         delegation.append({"files":files_per_app.copy(), "hostname":f"worker-target-{len(delegation)}"})



#     return delegation



# delegation = create_delegation(data_file_names)
# os.system(f"cd terraform && terraform init && terraform apply -auto-approve -var 'count_storage_instances=1' -var 'count_database_instances=1' -var 'count_worker_instances={len(delegation)}'")
# print(delegation)
# #os.system(f"cd ansible && ansible-playbook -i inventory.txt Ansible_Playbook.yaml -vvv -e '{str(delegation)}'")


import os
from pathlib import Path

project_directory = Path('_file_').parent
data_file_names = os.listdir(os.path.join(project_directory, "data"))


# print(data_file_names)


def create_delegation(data_file_names):
    delegation = []
    files_per_app = [] 
    for filename in data_file_names:
        files_per_app.append(filename)

        if len(files_per_app) >= 10:
            delegation.append({"files":files_per_app.copy(), "hostname":f"worker-target-{len(delegation)}"})
            files_per_app = []
    if len(files_per_app) > 0:
        delegation.append({"files":files_per_app.copy(), "hostname":f"worker-target-{len(delegation)}"})
    return {"delegation": delegation}



delegation = create_delegation(data_file_names)
os.system(f"cd terraform && terraform init && terraform apply -auto-approve -var 'count_storage_instances=0' -var 'count_database_instances=1' -var 'count_worker_instances={len(delegation['delegation'])}'")
print(delegation)
os.system(f"cd ansible && export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i inventory.txt Ansible_Playbook.yaml -vvv -e '{str(delegation)}'") # --limit worker
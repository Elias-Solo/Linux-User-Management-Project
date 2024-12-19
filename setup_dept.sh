#!/bin/bash

# Departments and their details
departments=(
  "Engineering:admin_engineering:user1_engineering:user2_engineering"
  "Sales:admin_sales:user1_sales:user2_sales"
  "Finances:admin_finances:user1_finances:user2_finances"
)

# Function to create a group
create_group() {
   group=$1
   echo "Creating group: $group"
   sudo groupadd $group
}

# Function to create a user
create_user() {
   username=$1
   group=$2
   echo "Creating user: $username in group: $group"
   sudo useradd -m -s /bin/bash -g $group $username
}

# Function to create a directory
create_directory() {
   directory=$1
   admin=$2
   group=$3
   echo "Creating directory: /$directory"
   sudo mkdir -p /$directory
   echo "Setting ownership of /$directory to $admin:$group"
   sudo chown $admin:$group /$directory
   echo "Setting permissions of /$directory to 770"
   sudo chmod 770 /$directory
   echo "Setting sticky bit on /$directory"
   sudo chmod +t /$directory
}

# Function to create a document
create_document() {
   directory=$1
   admin=$2
   group=$3
   document="/$directory/department_info.txt"
   echo "Creating document: $document"
   echo "This file contains confidential information for the department." | sudo tee $document > /dev/null
   echo "Setting ownership of $document to $admin:$group"
   sudo chown $admin:$group $document
   echo "Setting permissions of $document to 664"
   sudo chmod 664 $document
}

# Main setup process
echo "Starting department setup..."
for dept in "${departments[@]}"; do
    IFS=":" read -r department admin user1 user2 <<< "$dept"

    echo "Setting up department: $department"

    # Create group for the department
    create_group $department

    # Create admin and users
    create_user $admin $department
    create_user $user1 $department
    create_user $user2 $department

    # Create and configure directory
    create_directory $department $admin $department

    # Create document in directory
    create_document $department $admin $department

    echo "Completed setup for $department"
    echo "-------------------------------"
done

# Verification
echo "Verifying users and groups..."
for dept in "${departments[@]}"; do
    IFS=":" read -r department admin user1 user2 <<< "$dept"
    id $admin
    id $user1
    id $user2
done

echo "Verifying department directories and permissions..."
for dept in "${departments[@]}"; do
    IFS=":" read -r department admin user1 user2 <<< "$dept"
    ls -ld /$department
done

echo "Verifying department documents and permissions..."
for dept in "${departments[@]}"; do
    IFS=":" read -r department admin user1 user2 <<< "$dept"
    ls -l /$department/department_info.txt
done

echo "Department setup completed successfully!"

class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.text :password_digest
      # t.text :password
      # t.text :salt
      t.string :phone
      t.string :firstname
      t.string :lastname
      t.boolean :sex
      t.integer :age

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end

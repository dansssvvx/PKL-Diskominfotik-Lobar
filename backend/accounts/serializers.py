from rest_framework import serializers
from .models import User, Role

class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    role_name = serializers.ReadOnlyField(source='role.display_name')
    
    class Meta:
        model = User
        fields = (
            'id', 'email', 'fullname', 'phone', 
            'role', 'role_name', 'profile_photo', 
            'is_verified', 'is_active', 'date_joined'
        )
        read_only_fields = ('id', 'is_verified', 'is_active', 'date_joined')

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ('email', 'fullname', 'password', 'role')
        
    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            fullname=validated_data['fullname'],
            password=validated_data['password'],
            role=validated_data['role']
        )
        return user

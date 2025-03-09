import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Organization } from './entities/organization.entity';
import { CreateOrganizationDto } from './dto/create-organization.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class OrganizationsService {
  constructor(
    @InjectRepository(Organization)
    private organizationsRepository: Repository<Organization>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async create(createOrganizationDto: CreateOrganizationDto, userId: string): Promise<Organization> {
    const { name } = createOrganizationDto;

    // Check if organization with this name already exists
    const existingOrg = await this.organizationsRepository.findOne({ where: { name } });
    if (existingOrg) {
      throw new ConflictException('Organization with this name already exists');
    }

    // Create new organization
    const organization = this.organizationsRepository.create(createOrganizationDto);
    const savedOrg = await this.organizationsRepository.save(organization);

    // Associate creating user with the organization
    await this.usersRepository.update(userId, { organizationId: savedOrg.id });

    return savedOrg;
  }

  async findAll(): Promise<Organization[]> {
    return this.organizationsRepository.find();
  }

  async findOne(id: string): Promise<Organization> {
    const organization = await this.organizationsRepository.findOne({ where: { id } });
    if (!organization) {
      throw new NotFoundException(`Organization with ID ${id} not found`);
    }
    return organization;
  }

  async update(id: string, updateOrganizationDto: Partial<Organization>): Promise<Organization> {
    const organization = await this.findOne(id);
    const updatedOrg = this.organizationsRepository.merge(organization, updateOrganizationDto);
    return this.organizationsRepository.save(updatedOrg);
  }

  async remove(id: string): Promise<void> {
    const organization = await this.findOne(id);
    await this.organizationsRepository.remove(organization);
  }

  async findByUser(userId: string): Promise<Organization | null> {
    const user = await this.usersRepository.findOne({ where: { id: userId } });
    if (!user || !user.organizationId) {
      return null;
    }
    return this.findOne(user.organizationId);
  }

  async addUserToOrganization(userId: string, organizationId: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const organization = await this.findOne(organizationId);
    user.organizationId = organization.id;
    return this.usersRepository.save(user);
  }

  async getUsersInOrganization(organizationId: string): Promise<User[]> {
    return this.usersRepository.find({ where: { organizationId } });
  }
}
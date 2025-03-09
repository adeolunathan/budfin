import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req, ClassSerializerInterceptor, UseInterceptors } from '@nestjs/common';
import { OrganizationsService } from './organizations.service';
import { CreateOrganizationDto } from './dto/create-organization.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('organizations')
@UseInterceptors(ClassSerializerInterceptor)
export class OrganizationsController {
  constructor(private readonly organizationsService: OrganizationsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() createOrganizationDto: CreateOrganizationDto, @Req() req) {
    return this.organizationsService.create(createOrganizationDto, req.user.id);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  findAll() {
    return this.organizationsService.findAll();
  }

  @Get('my-organization')
  @UseGuards(JwtAuthGuard)
  findMyOrganization(@Req() req) {
    return this.organizationsService.findByUser(req.user.id);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string, @Req() req) {
    // TODO: Add check to ensure user belongs to the organization or is an admin
    return this.organizationsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() updateOrganizationDto: Partial<CreateOrganizationDto>, @Req() req) {
    // TODO: Add check to ensure user has rights to update the organization
    return this.organizationsService.update(id, updateOrganizationDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  remove(@Param('id') id: string) {
    return this.organizationsService.remove(id);
  }

  @Post(':id/users/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  addUser(@Param('id') id: string, @Param('userId') userId: string) {
    return this.organizationsService.addUserToOrganization(userId, id);
  }

  @Get(':id/users')
  @UseGuards(JwtAuthGuard)
  getUsers(@Param('id') id: string, @Req() req) {
    // TODO: Add check to ensure user belongs to the organization or is an admin
    return this.organizationsService.getUsersInOrganization(id);
  }
}
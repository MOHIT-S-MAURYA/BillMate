import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllCustomersUseCase {
  final BillingRepository repository;

  GetAllCustomersUseCase(this.repository);

  Future<List<Customer>> call() {
    return repository.getAllCustomers();
  }
}

@injectable
class GetCustomerByIdUseCase {
  final BillingRepository repository;

  GetCustomerByIdUseCase(this.repository);

  Future<Customer?> call(int id) {
    return repository.getCustomerById(id);
  }
}

@injectable
class SearchCustomersUseCase {
  final BillingRepository repository;

  SearchCustomersUseCase(this.repository);

  Future<List<Customer>> call(String query) {
    return repository.searchCustomers(query);
  }
}

@injectable
class CreateCustomerUseCase {
  final BillingRepository repository;

  CreateCustomerUseCase(this.repository);

  Future<Customer> call(Customer customer) {
    return repository.createCustomer(customer);
  }
}

@injectable
class UpdateCustomerUseCase {
  final BillingRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<void> call(Customer customer) {
    return repository.updateCustomer(customer);
  }
}

@injectable
class DeleteCustomerUseCase {
  final BillingRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteCustomer(id);
  }
}
